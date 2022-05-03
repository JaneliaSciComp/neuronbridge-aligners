cwlVersion: v1.0

baseCommand: /opt/aligner-scripts/run_aligner_using_s3.sh

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
    templatesBucket:
        type: Directory
        inputBinding:
            prefix: --templates-s3bucket-name
    inputsBucket:
        type: string
        inputBinding:
            prefix: --inputs-s3bucket-name
    inputPath:
        type: File
        inputBinding:
            prefix: -i
    outputsBucket:
        type: Directory
        inputBinding:
            prefix: --outputs-s3bucket-name
    outputDirectory:
        type: Directory
        inputBinding:
            prefix: -o
    iamRole:
        type: string
        inputBinding:
            prefix: --use-iam-role
    numberOfSlots:
        type: int
        inputBinding:
            prefix: --nslots
outputs:
    vaa3dResults:
        type: File
        outputBinding:
            glob: s3://$(inputs.outputsBucket)/$(inputs.outputDirectory)/*.v3dpbd
