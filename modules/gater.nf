#!/usr/bin/env nextflow
nextflow.enable.dsl=2

/*
 * GATER MODULE
 * For now, simply launches the docker container to run the Gater web server.
 */

workflow gater {
    take:
        allimg
        segMsk
        sft

    main:
        def regOrigDir = "${params.in}/registration"
        def quantOrigDir = "${params.in}/quantification"
        gating(allimg, segMsk, sft, regOrigDir, quantOrigDir)
}

process gating {
    // Output directory
    publishDir path: "${params.outdir}/gater", mode: 'copy'
    
    when:
        !params.skip_gater
    
    input:
        file allimg
        file segMsk
        file sft
        val regOrigDir
        val quantOrigDir

    script:
    """
    regPath="${regOrigDir}/\$(basename ${allimg})"
    quantPath="${quantOrigDir}/\$(basename ${sft})"
    
    echo "Registration full path: \$regPath"
    echo "Quantification full path: \$quantPath"
    # Launch the gater web server.
    docker run --rm -dp 8000:8000 \\
      -e MC_MICRO="true" \\
      -e REG_PATH="\$regPath" \\
      -e CSV_PATH="\$quantPath" \\
      -v "$PWD":"$PWD" -v "$PWD/gater":/gater -w "$PWD" \\
      aryaadesh/gater:1.1 &

    sleep 5

    # Cross-platform URL open command
    if [[ "\$OSTYPE" == "darwin"* ]]; then
        open http://localhost:8000
    elif [[ "\$OSTYPE" == "linux-gnu"* ]]; then
        xdg-open http://localhost:8000
    elif [[ "\$OSTYPE" == "msys" ]] || [[ "\$OSTYPE" == "cygwin" ]]; then
        start http://localhost:8000
    else
        echo "Please open http://localhost:8000 manually in your browser."
    fi

    # Wait until the gated CSV file is produced
    while [ ! -f gater/gated.csv ]; do
        echo "Waiting for gated CSV to be produced..."
        sleep 5
    done

    echo "Gated CSV found. Exiting process."
    """
}