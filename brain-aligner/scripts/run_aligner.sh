#!/bin/bash

echo "Run brain aligner with $*"

DIR=$(cd "$(dirname "$0")"; pwd)

xyres=1
zres=1
nslots=2
input_filepath=
output_dir=
use_voxel_resolution_args=false
reference_channel=Signal_amount
comparison_alg=Max

help_cmd="$0 
    --xyres <xy resolution in um>
    --zres <z resolution in um>
    --reference-channel <reference channel>
    --comparison-alg <comparison alg: {Max, Median}>
    --nslots <nslots (default = 2)>
    --templatedir <template config directory>
    --force-res <true|false>
    -i <input file stack>
    -o <output directory>
    -debug
    -h"

while [[ $# > 0 ]]; do
    key="$1"
    shift # past the key
    case $key in
        --xyres)
            xyres="$1"
            shift # past value
            ;;
        --zres)
            zres="$1"
            shift # past value
            ;;
        --force-res|--forceVxSize)
            if [[ "$1" =~ "true" ]] ; then
                # if arg is true use_voxel_resolution_args otherwise leave it false
                use_voxel_resolution_args=true
            fi
            shift
            ;;
        --nslots)
            nslots=$1
            shift
            ;;
        --templatedir)
            export TEMPLATE_DIR="$1"
            shift # past value
            ;;
        --reference-channel|--reference_channel)
            if [[ "$1" != "" ]] ; then
                reference_channel="$1"
            fi
            shift
            ;;
        --comparison-alg|--comparison_alg)
            comparison_alg="$1"
            shift
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

umask 0002

default_fb_mode="xvfb"
export NSLOTS=${NSLOTS:-$nslots}
export FB_MODE=${FB_MODE:-$default_fb_mode}
echo "Use FB_MODE=${FB_MODE}"

export WORKING_DIR="${output_dir}/temp"
echo "Create working directory ${WORKING_DIR}"
mkdir -p ${WORKING_DIR}
cd ${WORKING_DIR}

# set user directory to the working directory
JAVA_USER_DIR="${WORKING_DIR}"
echo "Set java user directory to ${JAVA_USER_DIR}"

export JAVA_TOOL_OPTIONS="-Duser.home=${JAVA_USER_DIR}"

function cleanTemp {
    if [[ "${DEBUG_MODE}" =~ "debug" ]]; then
        echo "~ Debugging mode - Leaving temp directory"
    else
        echo "Cleaning ${WORKING_DIR}"
        rm -rf ${WORKING_DIR}
        echo "Cleaned up ${WORKING_DIR}"
    fi
}

source ${XVFB_HELPER_SCRIPTS_DIR}/setup_xvfb.sh
function exitHandler() { exitXvfb; cleanTemp; }
trap exitHandler EXIT

ALIGNMENT_OUTPUT=${ALIGNMENT_OUTPUT:-"${output_dir}/aligned"}
mkdir -p ${ALIGNMENT_OUTPUT}

alignmentErrFile=${alignmentErrFile:-"${output_dir}/alignErr.txt"}
export FINALOUTPUT=${ALIGNMENT_OUTPUT}

echo "~ Run alignment: ${input_filepath} ${nslots} ${xyres} ${zres} ${use_voxel_resolution_args} ${reference_channel} ${comparison_alg} ${alignmentErrFile}"
/opt/aligner/20xBrain_Align_CMTK.sh ${input_filepath} ${nslots} ${xyres} ${zres} ${use_voxel_resolution_args} ${reference_channel} ${comparison_alg} ${alignmentErrFile}
alignmentExitCode=$?
if [ $alignmentExitCode -ne 0 ]; then
    echo "Alignment terminated with code ${alignmentExitCode}. Read error file: ${alignmentErrFile}"
    if [[ -e "${alignmentErrFile}" ]] ; then
        alignmentErr=$(cat "${alignmentErrFile}" || "")
        printf "Alignment error:\n${alignmentErr}\n"
    fi
    exit 1
fi

cd ${output_dir}
echo ""
echo "~ Listing working files:"
echo ""
tree -s $WORKING_DIR

alignment_results=$(shopt -s nullglob dotglob; echo ${ALIGNMENT_OUTPUT}/*.nrrd)
echo "Alignment results: ${alignment_results[@]}"
if (( ${#alignment_results} )); then
    echo "~ Finished alignment: ${input_filepath}"
    cleanTemp
    exit 0
else
    echo "~ No alignment results were found after alignment of ${input_filepath} ${WORKING_DIR} ${shape}"
    exit 1
fi
