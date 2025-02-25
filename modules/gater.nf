#!/usr/bin/env nextflow
nextflow.enable.dsl=2

/*
 * GATER MODULE
 * Inputs:
 *  1. A final (registered or background-subtracted) image channel
 *  2. A segmentation mask (nuclei or cell) channel
 *  3. A single-cell quantification CSV
 */

workflow gater {
    take:
        mcp
        allimg
        segMsk
        sft

    // Select segmentation masks based on user-specified mask type (cell or nuclei)
    main:
        def chosen_mask = segMsk.filter { seg_type, mask_path ->
            mask_path.getName().contains(params.mask_type)
        }

        // def gater_input = allimg.mix(chosen_mask).mix(sft)
        // Run the GATER process
        GATER_PROCESS(gater_input)
}


process GATER_PROCESS {
    tag { sample_id }

    // Use the Gater container
    container 'aryaadesh/gater:1.0'
    // Publish outputs (if any) to the specified directory
    publishDir path: "${params.outdir}/gater", mode: 'copy'
    
    // Only run if not skipped via params
    when:
    !params.skip_gater

    input:
    tuple val(sample_id), path(reg_ome), val(seg_type), path(mask_ome), val(sample2_id), path(quant_csv)
    
    script:
    """
    # Start the gater web server using outputs from previous steps.
    gater --out gater_output.csv &
    echo "Gater web server running on port 8000. You can access it at http://localhost:8000"
    # Keep the container running to allow human interaction.
    tail -f /dev/null
    """
}