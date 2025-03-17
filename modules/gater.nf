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
        def origRegDir = allimg.getParent()
        // def regOutDir   = "${params.in}/registration"
        // def segOutDir   = "${pubDir}/$tag"
        // def quantOutDir = "${params.in}/quantification"
        // Directly run the gating without processing upstream inputs.
        gating(allimg, segMsk, sft, origRegDir)
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
        val origRegDir

    script:
    """
    # Extract directory and file name for registration output
    reg_dir=\$(dirname ${origRegDir})
    reg_name=\$(basename ${allimg})

    # Extract directory and file name for segmentation output
    seg_dir=\$(dirname ${segMsk})
    seg_name=\$(basename ${segMsk})

    # Extract directory and file name for quantification output
    quant_dir=\$(dirname ${sft})
    quant_name=\$(basename ${sft})

    echo "Registration: Directory = \$reg_dir, File = \$reg_name"
    echo "Segmentation: Directory = \$seg_dir, File = \$seg_name"
    echo "Quantification: Directory = \$quant_dir, File = \$quant_name"
    # Launch the gater web server.
    docker run --rm -dp 8000:8000 \\
    -v "$PWD":"$PWD" -w "$PWD" \\
    aryaadesh/gater:1.1 & sleep 5 && open http://localhost:8000
    # Prevent process termination so the container stays alive.
    """
}