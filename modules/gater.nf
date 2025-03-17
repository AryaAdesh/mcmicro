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
    echo "Quantification full path: \$quantPath"}"
    # Launch the gater web server.
    docker run --rm -dp 8000:8000 \\
    -v "$PWD":"$PWD" -w "$PWD" \\
    aryaadesh/gater:1.1 & sleep 5 && open http://localhost:8000
    # Prevent process termination so the container stays alive.
    """
}