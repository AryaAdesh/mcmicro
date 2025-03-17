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
        // def regOutDir   = "${params.in}/registration"
        // def segOutDir   = "${pubDir}/$tag"
        // def quantOutDir = "${params.in}/quantification"
        // Directly run the gating without processing upstream inputs.
        gating(allimg, segMsk, sft)
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

    script:
    """
    # Extract directory and file name for registration output
    reg_dir=\$(dirname ${allimg.parent})
    reg_name=\$(basename ${allimg})

    # Extract directory and file name for segmentation output
    seg_dir=\$(dirname ${segMsk.parent})
    seg_name=\$(basename ${segMsk})

    # Extract directory and file name for quantification output
    quant_dir=\$(dirname ${sft.parent})
    quant_name=\$(basename ${sft})

    echo "Registration: Dir = \$reg_dir, File = \$reg_name"
    echo "Segmentation: Dir = \$seg_dir, File = \$seg_name"
    echo "Quantification: Dir = \$quant_dir, File = \$quant_name"
    # Launch the gater web server.
    docker run --rm -dp 8000:8000 \\
    -v "$PWD":"$PWD" -w "$PWD" \\
    aryaadesh/gater:1.1 & sleep 5 && open http://localhost:8000
    # Prevent process termination so the container stays alive.
    """
}