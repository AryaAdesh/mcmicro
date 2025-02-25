#!/usr/bin/env nextflow
nextflow.enable.dsl=2

/*
 * GATER MODULE
 * For now, simply launches the docker container to run the Gater web server.
 */

workflow gater {
    main:
        // Directly run the GATER_PROCESS without processing upstream inputs.
        GATER_PROCESS()
}

process GATER_PROCESS {
    // Output directory (if needed)
    publishDir path: "${params.outdir}/gater", mode: 'copy'
    
    when:
        !params.skip_gater

    script:
    """
    # Launch the gater web server.
    docker run --rm -dp 8000:8000 \\
    -v "$PWD":"$PWD" -w "$PWD" \\
    aryaadesh/gater:1.1
    # Prevent process termination so the container stays alive.
    """
}