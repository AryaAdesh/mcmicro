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
        def regPath = "($params.in)/registration/" + ${allimg}.name
        // def segPath = "($params.in)/segmentation" + ${segMsk}.name
        def quantPath = "($params.in)/quantification/" + ${sft}.name
        gating(regPath, quantPath)
}

process gating {
    // Output directory
    publishDir path: "${params.outdir}/gater", mode: 'copy'
    
    when:
        !params.skip_gater
    
    input:
        val regPath
        val quantPath

    script:
    """
    echo "Registration path = \$regpath"
    echo "quant path = \$quantPath"
    # Launch the gater web server.
    docker run --rm -dp 8000:8000 \\
    -v "$PWD":"$PWD" -w "$PWD" \\
    aryaadesh/gater:1.1 & sleep 5 && open http://localhost:8000
    # Prevent process termination so the container stays alive.
    """
}