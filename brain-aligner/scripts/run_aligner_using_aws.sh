#!/bin/bash

DIR=$(cd "$(dirname "$0")"; pwd)

S3_TEMPLATES_MOUNTPOINT=${S3_TEMPLATES_MOUNTPOINT:-"/s3_alignment_templates"}

templates_s3bucket_name=
inputs_s3bucket_name=
outputs_s3bucket_name=
searchId=
input_filepath=
output_dir=
templates_dir_param=
other_args=()
use_iam_role=
skipCopyInputIfExists=false
remove_input=false

help_cmd="$0 
    --templates-s3bucket-name <template S3 bucket name>
    --use-iam-role <iam role to be used by S3FS or auto, if not specified AWS keys must be set>
    --inputs-s3bucket-name <inputs S3 bucket name>
    --outputs-s3bucket-name <outputs S3 bucket name>
    --search-id <id of the search to be updated using AWS AppSync API>
    -i <input filepath in the inputs bucket>
    -o <output path in the outputs bucket>
    <other aligner args (see run_aligner.sh)>
    -debug <{true|false}>
    -h"

echo "Invoked neuronbridge aligner with $@"
while [[ $# > 0 ]]; do
    key="$1"
    shift # past the key
    case $key in
        --templates-s3bucket-name)
            templates_s3bucket_name="$1"
            shift # past value
            ;;
        --inputs-s3bucket-name)
            inputs_s3bucket_name="$1"
            shift # past value
            ;;
        --outputs-s3bucket-name)
            outputs_s3bucket_name="$1"
            shift # past value
            ;;
        --templatedir)
            templates_dir_param="$1"
            shift # past value
            ;;
        --search-id)
            searchId="$1"
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
        --use-iam-role)
            use_iam_role="$1"
            shift
            ;;
        -skipCopyInputIfExists)
            skipCopyInputIfExists=true
            ;;
        --rm)
            remove_input="$1"
            shift
            ;;
        -debug)
            debug_flag="$1"
            if [[ "${debug_flag}" =~ "true" ]] ; then
                export DEBUG_MODE=debug
            fi
            shift
            ;;
        -h|--help)
            echo "${help_cmd}"
            exit 0
            ;;
        *)
            other_args=("${other_args[@]}" "${key}")
            ;;
    esac
done

export AWSACCESSKEYID=${AWSACCESSKEYID:-$AWS_ACCESS_KEY_ID}
export AWSSECRETACCESSKEY=${AWSSECRETACCESSKEY:-$AWS_SECRET_ACCESS_KEY}

# the script assumes there is a /scratch directory available
# the working directory is based on the output directory last component name
output_basename=`basename "${output_dir}"`
WORKING_DIR="/scratch/${output_basename}"
echo "Create local working directory '${WORKING_DIR}'"
mkdir -p "${WORKING_DIR}"

function cleanWorkingDir() {
    if [[ "${DEBUG_MODE}" =~ "debug" ]] ; then
        echo "~ Debugging mode - Leaving working directory"
    else
        echo "Cleaning ${WORKING_DIR}"
        rm -rf "${WORKING_DIR}"
        echo "Cleaned up ${WORKING_DIR}"
    fi
}
trap cleanWorkingDir EXIT

function updateSearch() {
    local -a args=("${@}")
    local searchId=${args[0]}
    local -i searchStep=${args[1]}
    local -i with_ts=${args[2]}
    local alignmentMovieParam=${args[3]}
    local alignmentScore=${args[4]}
    local -i nMips=${args[5]}
    local -a mipsParam
    if [ $nMips -eq 0 ] ; then
        mipsParam=()
    else
        mipsParam=("${args[@]:6:$nMips}")
    fi
    local errorMessage=${args[6+$nMips]}

    local alignedTimestamp=
    if [[ ${with_ts} == 1 ]] ; then
        alignedTimestamp=`date --utc +%FT%TZ`
    fi
    local alignmentMovie=
    if [[ ${alignmentMovieParam} != "None" ]] ; then
        alignmentMovie=${alignmentMovieParam}
    fi

    echo "Update Search Params: \
        searchId: ${searchId} \
        searchStep: ${searchStep} \
        alignFinished: ${alignedTimestamp} \
        nMips: ${nMips} \
        mips: ${mipsParam[@]} \
        alignmentMovie: ${alignmentMovieParam} \
        alignmentScore: ${alignmentScore} \
        errors: ${errorMessage}"

    # Update the search if a searchId is passed
    if [[ "${searchId}" != "" ]] ; then
        if ((${nMips} == 0)) ; then
            mipsList=
            thumbnail=
        else
            mipsList=$(printf ",\"%s\"" "${mipsParam[@]}")
            mipsList=${mipsList:1}
            thumbnail="${mipsParam[0]}"
        fi
        if [[ "${errorMessage}" == "" ]] ; then
            searchData="{
                \"searchId\": \"${searchId}\",
                \"step\": ${searchStep},
                \"alignFinished\": \"${alignedTimestamp}\",
                \"computedMIPs\": [ ${mipsList} ],
                \"uploadThumbnail\": \"${thumbnail}\",
                \"alignmentMovie\": \"${alignmentMovie}\",
                \"alignmentScore\": \"${alignmentScore}\"
            }"
        else
            searchData="{
                \"searchId\": \"${searchId}\",
                \"step\": ${searchStep},
                \"computedMIPs\": [ ${mipsList} ],
                \"uploadThumbnail\": \"${thumbnail}\",
                \"alignmentErrorMessage\": \"${errorMessage}\"
            }"
        fi
        echo ${searchData} > "${WORKING_DIR}/${searchId}-input.json"
        echo "SearchData: $(cat "${WORKING_DIR}/${searchId}-input.json")"
        printf -v updateSearchCmd "aws lambda invoke --function-name %s --log-type None --payload %s %s" \
            "${SEARCH_UPDATE_FUNCTION}" \
            "fileb://${WORKING_DIR}/${searchId}-input.json" \
            "${WORKING_DIR}/${searchId}.json"
        echo "Update search step: ${updateSearchCmd}"
        ${updateSearchCmd}
    fi
}

# create inputs and outputs directories
inputs_dir="${WORKING_DIR}/inputs"
results_dir="${WORKING_DIR}/results"

echo "Create local inputs directory ${inputs_dir} for searchId: ${searchId}"
mkdir -p "${inputs_dir}"
echo "Create local results directory ${results_dir} for searchId: ${searchId}"
mkdir -p "${results_dir}"

# copy input file to the input working directory
echo "Input filepath: ${input_filepath}"
input_filename=$(basename "${input_filepath}")
echo "Input filename: ${input_filename}"
# replace all spaces in the filename
working_input_filepath=${inputs_dir}/${input_filename// /_}
echo "Working input file path: ${working_input_filepath}"
copyInputsCmd="aws s3 cp \"s3://${inputs_s3bucket_name}/${input_filepath}\" \"${working_input_filepath}\" --no-progress"

if [[ "${skipCopyInputIfExists}" =~ "true" ]] ; then
    if [[ ! -e ${working_input_filepath} ]] ;  then
        echo "Copy inputs: ${copyInputsCmd}"
        cpInputRes=$(eval ${copyInputsCmd})
        echo "Copy input result: ${cpInputRes}"
    fi
else
    echo "Copy inputs: ${copyInputsCmd}"
    cpInputRes=$(eval ${copyInputsCmd})
    echo "Copy input result: ${cpInputRes}"
fi

if [[ "${templates_s3bucket_name}" != "" ]] ; then
    echo "Mount S3 templates buckets using s3fs"

    s3fs_opts="-o use_path_request_style,nosscache"
    if [[ "${use_iam_role}" != "" ]] ; then
        s3fs_opts="${s3fs_opts} -o iam_role=${use_iam_role}"
    elif [[ "${AWSACCESSKEYID}" != "" ]] ; then
        passwd_file=/scratch/.passwd-s3fs
        echo $AWSACCESSKEYID:$AWSSECRETACCESSKEY > ${passwd_file}
        chmod 600 ${passwd_file}
        s3fs_opts="${s3fs_opts} -o passwd_file=${passwd_file}"
    fi
    # mount templates directory
    mountTemplatesCmd="/usr/bin/s3fs ${templates_s3bucket_name} ${S3_TEMPLATES_MOUNTPOINT} ${s3fs_opts}"
    echo "Mount templates from S3: ${mountTemplatesCmd}"
    ${mountTemplatesCmd}
    if [[ "${templates_dir_param}" != "" ]] ; then
        templates_dir=${S3_TEMPLATES_MOUNTPOINT}/${templates_dir_param}
    else
        templates_dir=${S3_TEMPLATES_MOUNTPOINT}
    fi
    lsTemplatesCmd="ls ${templates_dir}"
    templatesCount=`${lsTemplatesCmd} | wc -l`
    echo "Found ${templatesCount} after running ${lsTemplatesCmd}"
    templates_dir_arg="--templatedir ${templates_dir}"
else
    # will use default templates
    templates_dir_arg=""
fi

export ALIGNMENT_OUTPUT="${results_dir}/alignment_results"
export MIPS_OUTPUT="${results_dir}/mips"

declare -a mips=()
alignmentMovie="None"
alignmentScore="0"

echo "Set alignment in progress for ${searchId}: ${mips[@]}"
updateSearch "${searchId}" 1 0 ${alignmentMovie} ${alignmentScore} ${#mips[@]} "${mips[@]}"

run_align_cmd_args=(
    ${templates_dir_arg}
    -i "${working_input_filepath}"
    -o "${results_dir}"
    "${other_args[@]}"
)

echo "Run: /opt/aligner-scripts/run_aligner.sh ${run_align_cmd_args[@]}"
export alignmentErrFile="${results_dir}/alignErr.txt"
/opt/aligner-scripts/run_aligner.sh "${run_align_cmd_args[@]}"
alignment_exit_code=$?
if [[ "${alignment_exit_code}" != "0" ]] ; then
    if [[ -e "${alignmentErrFile}" ]] ; then
        alignmentErr=$(cat "${alignmentErrFile}" || "")
        echo "Alignment error: ${alignmentErr}"
    else
        echo "Exit with error (${alignment_exit_code}) but could not find alignment error file: ${alignmentErrFile}"
        alignmentErr=''
    fi
    echo "Alignment exited with ${alignment_exit_code}: ${alignmentErr}";
    if [[ ! -z "${alignmentErr}" ]]; then
        errorMessage=${alignmentErr}
    else
        errorMessage="Alignment failed with exit code ${alignment_exit_code}"
    fi
    updateSearch "${searchId}" 1 0 ${alignmentMovie} ${alignmentScore} ${#mips[@]} "${mips[@]}" "${errorMessage}"
    exit $alignment_exit_code
fi

# copy the results to the s3 output bucket
generatedMIPSFolderName="generatedMIPS"
copyMipsCmd="aws s3 cp ${MIPS_OUTPUT} s3://${outputs_s3bucket_name}/${output_dir}/${generatedMIPSFolderName} --recursive"
echo "Copy MIPS: ${copyMipsCmd}"
${copyMipsCmd}

for mip in `ls ${MIPS_OUTPUT}/*.{tif,png,jpg}` ; do
    mips=("${mips[@]}" "${generatedMIPSFolderName}/$(basename ${mip})")
done

# copy additional results to the s3 output
for aresult in `find ${ALIGNMENT_OUTPUT} -maxdepth 1 -regextype posix-extended -regex ".*\.(txt|jpg|png|mp4|yaml|yml|property)"` ; do
    aresult_name=$(basename ${aresult})
    if [[ ${aresult_name} == *.mp4 ]] ; then
        alignmentMovie="alignment_results/${aresult_name}"
    elif [[ ${aresult_name} == *.property ]] ; then
        alignmentScore=$(cat ${aresult})
        if [[ -z "${alignmentScore}" ]] ; then
            echo "Alignment score not found - either ${ALIGNMENT_OUTPUT}/alignment_results/JRC2018_UNISEX_20x_HR_Score.property was missing or it was empty"
            alignmentScore="0"
        fi
    fi
    aws s3 cp ${aresult} s3://${outputs_s3bucket_name}/${output_dir}/alignment_results/${aresult_name}
done

echo "Set alignment to completed for ${searchId}: ${mips[@]}"
updateSearch "${searchId}" 2 1 ${alignmentMovie} ${alignmentScore} ${#mips[@]} "${mips[@]}"

if [[ "${DEBUG_MODE}" != "debug" ]] ; then
    echo "Remove working input copy: ${working_input_filepath}"
    rm -f ${working_input_filepath}
fi

if [[ "${remove_input}" =~ "true" ]] ; then
    # delete the input
    echo "Remove s3://${inputs_s3bucket_name}/${input_filepath}"
    aws s3 rm "s3://${inputs_s3bucket_name}/${input_filepath}"
fi
