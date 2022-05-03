cwlVersion: v1.0

baseCommand: /opt/aligner-scripts/run_aligner_and_cdm.sh

inputs:
    xyres:
        type: string
        inputBinding:
            prefix: --xyres
    zres:
        type: string
        inputBinding:
            prefix: --zres
    numberOfChannels:
        type: int
        inputBinding:
            prefix: --nchannels
    templateDirectory:
        type: Directory
        inputBinding:
            prefix: --templatedir
    input:
        type: File
        inputBinding:
            prefix: -i
    outputDirectory:
        type: Directory
        inputBinding:
            prefix: -o
    numberOfSlots:
        type: int
        inputBinding:
            prefix: --nslots
outputs:
    vaa3dResults:
        type: File
        outputBinding:
            glob: $(inputs.outputDirectory)/*.v3dpbd
