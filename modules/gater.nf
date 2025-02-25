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
    // Use Gater container and map port 8000.
    container 'aryaadesh/gater:1.0'
    containerOptions '-p 8000:8000 -v "$PWD":"$PWD" -w "$PWD"'
    
    // Output directory (if needed)
    publishDir path: "${params.outdir}/gater", mode: 'copy'
    
    when:
        !params.skip_gater

    script:
    """
    # Launch the gater web server.
    gater 
    # Prevent process termination so the container stays alive.
    tail -f /dev/null
    """
}