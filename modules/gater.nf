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
    // Segmentation masks chosen by the user either cell or nuclei
    main:
      
        def chosen_mask = segMsk.filter { seg_type, mask_path ->
            mask_path.getName().contains(params.mask_type)
        }

        def gater_input = allimg.mix(chosen_mask).mix(sft)
        // Run GATER
        GATER_PROCESS(gater_input)

    emit:
        GATER_PROCESS.out into gater_out
}


process GATER_PROCESS {
    tag { sample_id }

    // Use Gater container
    container 'aryaadesh/gater:1.0'

    // Output directory
    publishDir path: "${params.outdir}/gater", mode: 'copy'
    // Run gater or not based on the skip_gater parameter
    when:
    !params.skip_gater

    input:
    tuple val(sample_id), path(reg_ome), val(seg_type), path(mask_ome), val(sample2_id), path(quant_csv)

    //Output
    output:
    tuple val(sample_id), path("gater_output.csv")

    script:
    """
    echo "[GATER] Sample: ${sample_id}"
    echo "[GATER] Registration OME:  ${reg_ome}"
    echo "[GATER] Segmentation Mask: ${mask_ome}"
    echo "[GATER] Quant CSV:         ${quant_csv}"

    docker run --rm -dp 8000:8000 \\
        -v "\$PWD":"\$PWD" -w "\$PWD" \\
        aryaadesh/gater:1.0 \\
        gater \\
          --csv \${quant_csv} \\
          --images \${reg_ome} \${mask_ome} \\
          --out gater_output.csv

    echo "[GATER] Gater is now running in the background on port 8000."
    echo "[GATER] Open your browser at http://localhost:8000 to do manual gating."
    """
}
