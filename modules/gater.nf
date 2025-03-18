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
        def originalDir = "${params.in}"
        gating(allimg, segMsk, sft, regOrigDir, quantOrigDir, originalDir)
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
        val originalDir

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
      -e ORIGINAL_DIR="${originalDir}" \\
      -v "$PWD":"$PWD" -v "$PWD/gater":/gater -w "$PWD" \\
      aryaadesh/gater:1.2 &

    sleep 5

    # Cross-platform URL open command
    if [[ "\$OSTYPE" == "darwin"* ]]; then
        open http://localhost:8000/upload_page
    elif [[ "\$OSTYPE" == "linux-gnu"* ]]; then
        xdg-open http://localhost:8000/upload_page
    elif [[ "\$OSTYPE" == "msys" ]] || [[ "\$OSTYPE" == "cygwin" ]]; then
        start http://localhost:8000/upload_page
    else
        echo "Please open http://localhost:8000/upload_page manually in your browser."
    fi

    """
}