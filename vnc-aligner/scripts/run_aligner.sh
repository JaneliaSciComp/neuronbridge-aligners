#!/bin/bash

echo "Run VNC aligner with $*"

DIR=$(cd "$(dirname "$0")"; pwd)

help_cmd="$0 
    --nslots <nslots (default = 2)>
    --templatedir <template config directory>
    -i <input file stack>
    -o <output directory>
    -debug
    -h"

while [[ $# > 0 ]]; do
    key="$1"
    shift # past the key
    case $key in
        --nslots)
            nslots=$1
            shift
            ;;
        --miptemplatedir)
            export MIP_TEMPLATE_DIR="$1"
            shift # past value
            ;;
        --aligntemplatedir)
            export ALIGN_TEMPLATE_DIR="$1"
            shift # past value
            ;;
        -i|--input)
            input_filepath="$1"
            shift # past value
            ;;
        -o|--output)
            output_dir="$1"
            shift # past value
            ;;
        -debug)
            export DEBUG_MODE=debug
            # no need to shift
            ;;
        -h|--help)
            echo "${help_cmd}"
            exit 0
            ;;
        *)
            echo "Unknown flag ${key}"
            echo "${help_cmd}"
            exit 1
            ;;
    esac
done

if [ ! -e "${input_filepath}" ]; then
    echo "Input file path ${input_filepath} not found"
    exit 1
fi

umask 0002
export NSLOTS=${NSLOTS:-$nslots}
export WORKING_DIR="${output_dir}/temp"

echo "Create working directory ${WORKING_DIR}"
mkdir -p ${WORKING_DIR}
cd ${WORKING_DIR}

ALIGNMENT_OUTPUT=${ALIGNMENT_OUTPUT:-"${output_dir}/aligned"}
mkdir -p ${ALIGNMENT_OUTPUT}

alignmentErrFile=${alignmentErrFile:-"${output_dir}/alignErr.txt"}
export FINALOUTPUT=${ALIGNMENT_OUTPUT}

echo "~ Run alignment: ${input_filepath} ${nslots} ${xyres} ${zres} ${use_voxel_resolution_args} ${reference_channel} ${comparison_alg} ${alignmentErrFile}"
/opt/aligner/20x40xVNC_Align_CMTK.sh ${input_filepath} ${nslots} ${FINALOUTPUT} ${alignmentErrFile}
alignmentExitCode=$?

if [ $alignmentExitCode -ne 0 ]; then
    alignmentErr=$(cat "${alignmentErrFile}" || "")
    echo "Alignment terminated abnormally ${alignmentErr}"
    exit 1
fi
