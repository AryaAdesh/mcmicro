#!/usr/bin/env nextflow
nextflow.enable.dsl=2

/*
 * GATER MODULE
 * For now, simply launches the docker container to run the Gater web server.
 */

workflow gater {
    take:
        sft
    main:
        // Directly run the gating without processing upstream inputs.
        gating(sft)
}

process gating {
    // Output directory
    publishDir path: "${params.outdir}/gater", mode: 'copy'
    
    when:
        !params.skip_gater
    
    input:
        path sft

    script:
    """
    # Launch the gater web server.
    docker run --rm -dp 8000:8000 \\
    -v "$PWD":"$PWD" -w "$PWD" \\
    aryaadesh/gater:1.1 & sleep 5 && open http://localhost:8000
    # Prevent process termination so the container stays alive.
    """
}