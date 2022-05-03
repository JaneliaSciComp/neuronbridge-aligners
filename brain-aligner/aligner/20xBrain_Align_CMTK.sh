#!/bin/bash
#
# 20x 40x brain aligner by Hideo Otsuna
#

InputFilePath=$1
NSLOTS=$2
# Resolutions in microns
RESX=$3
RESZ=$4

# true or false, forcefully use the user input or the size from confocal file
ForceUseVxSize=$5
# Reference channel can be one of: {ch1, ch2, ch3, ch4, Signal_amount}
# If the value is ch<number> it considers that channel as the reference channel
# If the value is 'Signal_amount' it will compare sum signal between all channels, 
# and choose the reference channel the one with the highest sum
referenceChannel=$6
comparisonAlg=$7
returnedErrorFilename=$8

InputFileName=$(basename ${InputFilePath})
InputName=${InputFileName%.*}
InputFileParentPath=$(dirname ${InputFilePath})

WORKING_DIR=${WORKING_DIR:-"${InputFileParentPath}/${InputName}_TMP"}
DEBUG_DIR="${WORKING_DIR}/Debug"
OUTPUT="${WORKING_DIR}/Output"
FINALOUTPUT=${FINALOUTPUT:-"${WORKING_DIR}/FinalOutputs"}

TEMPLATE_DIR=${TEMPLATE_DIR:-"/data/alignment_templates"}
TemplatesDir=`realpath ${TEMPLATE_DIR}`

echo "InputFilePath: ${InputFilePath}"
echo "InputFileName: ${InputFileName}"
echo "InputName: ${InputName}"
echo "ForceUseVxSize: ${ForceUseVxSize}"
echo "NSlots: ${NSLOTS}"
echo "RESX: ${RESX}"
echo "RESZ: ${RESZ}"
echo "TEMPLATE_DIR: ${TEMPLATE_DIR}"
echo "WORKING_DIR: ${WORKING_DIR}"
echo "OUTPUT: ${OUTPUT}"
echo "ReferenceChannel: ${referenceChannel}"
echo "ComparisonAlg: ${comparisonAlg}"

# Tools
CMTK=/opt/CMTK/bin
FIJI=/opt/Fiji/ImageJ-linux64
Vaa3D=/opt/Vaa3D/vaa3d
MACRO_DIR=/opt/aligner/fiji_macros

# Fiji macros
MIPGENERATION="${MACRO_DIR}/Color_Depth_MIP_batch_0404_2019_For_Pipeline.ijm"
NRRDCONV="${MACRO_DIR}/nrrd2v3draw.ijm"
PREPROCIMG="${MACRO_DIR}/20x_40x_Brain_Global_Aligner_Pipeline.ijm"
TWELVEBITCONV="${MACRO_DIR}/12bit_Conversion.ijm"
SCOREGENERATION="${MACRO_DIR}/Score_Generator_Cluster.ijm"
REGCROP="${MACRO_DIR}/TempCrop_after_affine.ijm"

BrainShape="Both_OL_missing (40x)"
objective="20x"
templateBr="JRC2018"

# Reformat a single NRRD file to the target deformation field
function reformat() {
    local _gsig="$1"
    local _TEMPLATE="$2"
    local _DEFFIELD="$3"
    local _sig="$4"
    local _channel="$5"
    local _result_var="$6"
    local _opts="$7"

    if [[ -e $_sig ]]; then
        echo "Already exists: $_sig"
    else
        echo "--------------"
        echo "Running CMTK reformatting on channel ${_channel}"
        echo "$CMTK/reformatx --threads ${NSLOTS} -o ${_sig} ${_opts} --floating ${_gsig} ${_TEMPLATE} ${_DEFFIELD}"
        START=`date '+%F %T'`
        $CMTK/reformatx -o "${_sig}" ${_opts} --floating ${_gsig} ${_TEMPLATE} ${_DEFFIELD}
        STOP=`date '+%F %T'`

        if [[ ! -e $_sig ]]; then
            echo -e "Error: CMTK reformatting signal failed"
            exit -1
        fi

        echo "--------------"
        echo "cmtk_reformatting ${_channel} start: $START"
        echo "cmtk_reformatting ${_channel} stop: $STOP"
        echo " "
    fi
}

# Reformat all the channels to the same template
function reformatAll() {
    local _gsig="$1"
    local _TEMPLATE="$2"
    local _DEFFIELD="$3"
    local _sig="$4"
    local _result_var="$5"
    local _opts="$6"

    echo "Reformat all channels -> [1..$NCHANNELS]"
    # Reformat each channel
    for ((i=1; i<=$NCHANNELS; i++)); do
        echo "Reformat channel ${i}"
        GLOBAL_NRRD="${_gsig}_0${i}.nrrd"
        OUTPUT_NRRD="${_sig}_0${i}.nrrd"
        reformat "${GLOBAL_NRRD}" "${_TEMPLATE}" "${_DEFFIELD}" "${OUTPUT_NRRD}" "${i}" "ignore" "${opts}"
    done
}

# Alignment score generation
function scoreGen() {
    local _outname="$1"
    local _scoretemp="$2"
    local _result_var="$3"

    tempfilename=`basename $_scoretemp`
    tempname=${tempfilename%%.*}
    scorepath="$OUTPUT/${tempname}_Score.property"

     if [[ -e ${scorepath} ]]; then
        echo "Already exists: $scorepath"
    else
        echo "+---------------------------------------------------------------------------------------+"
        echo "| Running Score generation"
        echo "| $FIJI --headless -macro ${SCOREGENERATION} ${OUTPUT}/,${_outname},${NSLOTS},${_scoretemp}"
        echo "+---------------------------------------------------------------------------------------+"

        START=`date '+%F %T'`
        # Expect to take far less than 1 hour
	    # Alignment Score generation:ZNCC can run in headless mode (no X11 needed)	
        $FIJI --headless -macro ${SCOREGENERATION} ${OUTPUT}/,${_outname},${NSLOTS},${_scoretemp}
        STOP=`date '+%F %T'`

        echo "ZNCC JRC2018 score generation start: $START"
        echo "ZNCC JRC2018 score generation stop: $STOP"
    fi
}

function generateAllMIPs() {
    local _sigDir=$1
    local _sigBaseName=$2
    local _mipsOutput=$3
    local area="Brain"
    # generate MIPs for all signal channels ...
    echo "Generate MIPs for all signal channels to ${_mipsOutput}"
    for ((i=1; i<=$NCHANNELS; i++)); do
        mipCmdArgs="${_sigDir}/,${_sigBaseName}_0${i}.nrrd,${_mipsOutput}/,${TemplatesDir}/,${area}"
        mipsCmd="$FIJI --headless -macro ${MIPGENERATION} ${mipCmdArgs}"
        echo "Generate MIPS for channel ${i}: ${mipsCmd}"
        ${mipsCmd}
        echo "Generated MIPS for channel ${i}"
    done
    echo "Finished MIPs generation for all signal channels"
}

function checkTimeout() {
    local cpid=$1;
    local timeoutVal=$2;
    local inc=$3
    local errHandler=$4
    local  __exitStatusVar=$5

    # check for timeout
    runningTime=0
    psflags="-p ${cpid} --no-headers -o %cpu,%mem,cmd"
    while ps ${psflags} ; do
        if [ ${runningTime} -ge ${timeoutVal} ]; then
            ${errHandler}
            kill -9 $cpid
            break
        else
            sleep $inc
            runningTime=$((runningTime+inc))
        fi
    done
    wait $cpid
    eval $__exitStatusVar=$?
}

function banner() {
    echo "------------------------------------------------------------------------------------------------------------"
    echo " $1"
    echo "------------------------------------------------------------------------------------------------------------"
}

# Main Script

mkdir -p $WORKING_DIR
mkdir -p $OUTPUT
mkdir -p $DEBUG_DIR
mkdir -p $FINALOUTPUT

if [[ ! -e $PREPROCIMG ]]; then
    echo "Preprocess macro could not be found at $PREPROCIMG"
    exit 1
fi

if [[ ! -e $FIJI ]]; then
    echo "Fiji cannot be found at $FIJI"
    exit 1
fi

# neuron mask is ignored
Unaligned_Neuron_Separator_Result_V3DPBD=

# "-------------------Template----------------------"
JRC2018_Unisex_Onemicron1="${TemplatesDir}/JRC2018_UNISEX_20x_onemicron.nrrd"
JRC2018_Unisex_OnemicronNoOL="${TemplatesDir}/JRC2018_UNISEX_20x_gen1_noOPonemicron.nrrd"
JRC2018_Unisexgen1CROPPED="${OUTPUT}/TempCROPPED.nrrd"

# "-------------------Global aligned files----------------------"
gloval_nc82_nrrd="${OUTPUT}/${InputName}_01.nrrd"
gloval_signalNrrd1="${OUTPUT}/${InputName}_02.nrrd"
gloval_signalNrrd2="${OUTPUT}/${InputName}_03.nrrd"
gloval_signalNrrd3="${OUTPUT}/$InputName}_04.nrrd"

# "-------------------Deformation fields----------------------"
registered_initial_xform="${OUTPUT}/initial.xform"
registered_affine_xform="${OUTPUT}/affine.xform"
registered_warp_xform="${OUTPUT}/warp.xform"

# -------------------------------------------------------------------------------------------
OLSHAPE="${OUTPUT}/OL_shape.txt"
METADATA="${OUTPUT}/metadata.yaml"

memResource=${ALIGNMENT_MEMORY:-"2G"}
if [[ -e ${OLSHAPE} && -e ${METADATA} ]]; then
    echo "Already exists: ${OLSHAPE} and ${METADATA}"
else
    preprocessingParams="${OUTPUT}/,${InputName}.,${InputFilePath},${TemplatesDir},${RESX},${RESZ},${NSLOTS},${objective},${templateBr},${BrainShape},${Unaligned_Neuron_Separator_Result_V3DPBD},${ForceUseVxSize},${referenceChannel},${comparisonAlg}"
    fijiOpts="--ij2 --mem ${memResource} --info --no-splash"
    echo "+---------------------------------------------------------------------------------------+"
    echo "| Running OtsunaBrain preprocessing step"
    echo "| ${FIJI} ${fijiOpts} -macro ${PREPROCIMG} \"${preprocessingParams}\""
    echo "+---------------------------------------------------------------------------------------+"
    START=`date '+%F %T'`
    # Start the preprocessing in background and then wait until it finishes or times out.
    # Note that this macro does not seem to work in --headless mode
    PREALIGN_TIMEOUT=$((${PREALIGN_TIMEOUT:-9000}))
    PREALIGN_CHECKINTERVAL=$((${PREALIGN_CHECKINTERVAL:-60}))
    (${FIJI} ${fijiOpts} -macro ${PREPROCIMG} "${preprocessingParams}" > ${DEBUG_DIR}/preproc.log 2>&1) &
    fpid=$!

    function prealignTimeoutHandler {
        echo "Fiji preprocessing timed out -  killing the process"
        source ${XVFB_HELPER_SCRIPTS_DIR}/xvfb_functions.sh
        screenSnapshot
        eval "ALIGNMENT_ERROR=\"Preprocessing timed out\""
    }

    # check for timeout
    checkTimeout \
        $fpid \
        ${PREALIGN_TIMEOUT} \
        ${PREALIGN_CHECKINTERVAL} \
        prealignTimeoutHandler \
        preprocessExitCode

    STOP=`date '+%F %T'`
    echo "Otsuna_Brain preprocessing start: $START"
    echo "Otsuna_Brain preprocessing stop: $STOP"

    # check for prealigner errors
    LOGFILE="${OUTPUT}/20x_brain_pre_aligner_log.txt"
    cp $LOGFILE $DEBUG_DIR

    # check if there were errors
    if [[ ${preprocessExitCode} -eq 0 ]] ; then
        coreDumpError=`grep SIGSEGV $DEBUG_DIR/preproc.log`
        preAlignerError=`grep "PreAlignerError: " $LOGFILE | head -n1 | sed "s/PreAlignerError: //"`
        memoryError=`grep -i "Cannot allocate memory" $LOGFILE | head -n1`
        outOfMemoryError=`grep -i "out of memory" $LOGFILE | head -n1`
        if [[ ! -z "${coreDumpError}" ]] ; then
            ALIGNMENT_ERROR="Preprocessing failed with a fatal error"
        elif [[ ! -z "${preAlignerError}" ]] ; then
            ALIGNMENT_ERROR=${preAlignerError}
        elif [[ ! -z "${memoryError}" || ! -z "${outOfMemoryError}" ]] ; then
            ALIGNMENT_ERROR="Out of memory error";
        fi
    fi

    if [[ ! -z "${ALIGNMENT_ERROR}" ]]; then
        echo "~ Preprocessing output"
        tail -1000 $DEBUG_DIR/preproc.log
        echo "~ Preprocessing log"
        cat ${LOGFILE}
        echo "~ Preprocessing error: ${ALIGNMENT_ERROR}"
        echo ${ALIGNMENT_ERROR} > ${returnedErrorFilename} 
        exit 1
    elif [[ ${DEBUG_MODE} =~ "debug" ]]; then
        echo "~ Preprocessing output"
        tail -1000 $DEBUG_DIR/preproc.log
        echo "~ Preprocessing log"
        cat ${LOGFILE}
    fi
fi

OL="$(<$OLSHAPE)"
echo "OLSHAPE; "$OL

if [[ ${DEBUG_MODE} =~ "debug" ]]; then
    echo "~ Metadata output"
    cat ${METADATA}
    echo ""
fi

# get the num channels and reference channel from metadata output
NCHANNELS=`yq -r .numChannels ${METADATA}`
referenceChannel=`yq -r .referenceChannel ${METADATA}`
echo "NCHANNELS=${NCHANNELS}, referenceChannel=${referenceChannel}"

iniT=${JRC2018_Unisex_Onemicron1}
if [[ ! -e ${JRC2018_Unisexgen1CROPPED} ]]; then
    cp ${JRC2018_Unisex_Onemicron1} ${JRC2018_Unisexgen1CROPPED}
fi

echo "iniT: $iniT"
echo "gloval_nc82_nrrd: $gloval_nc82_nrrd"
echo ""

# -------------------------------------------------------------------------------------------
if [[ -e ${registered_affine_xform} ]]; then
    echo "Already exists: $registered_affine_xform"
else
    echo "+----------------------------------------------------------------------+"
    echo "| Running CMTK registration"
    echo "| $CMTK/registration --threads $NSLOTS --initial $registered_initial_xform --dofs 6,9 --auto-multi-levels 4 --accuracy 0.8 -o $registered_affine_xform $iniT $gloval_nc82_nrrd "
    echo "+----------------------------------------------------------------------+"
    START=`date '+%F %T'`
    $CMTK/registration --threads $NSLOTS -i -v --dofs 6 --dofs 9 --accuracy 0.8 -o ${registered_affine_xform} ${iniT} ${gloval_nc82_nrrd}
    STOP=`date '+%F %T'`
    if [[ ! -e $registered_affine_xform ]]; then
        echo -e "Error: CMTK registration failed"
        exit -1
    fi
    echo "cmtk_registration start: $START"
    echo "cmtk_registration stop: $STOP"

    sig="${OUTPUT}/Affine_${InputName}_01.nrrd"
    DEFFIELD=${registered_affine_xform}
    TEMP=${JRC2018_Unisexgen1CROPPED}
    gsig=${gloval_nc82_nrrd}
    iniT=${JRC2018_Unisexgen1CROPPED}

    $CMTK/reformatx -o "$sig" --floating $gsig $TEMP $DEFFIELD
    $FIJI -macro $REGCROP "$TEMP,$sig,$NSLOTS"
fi

# CMTK warping
if [[ -e $registered_warp_xform ]]; then
    echo "Already exists: $registered_warp_xform"
else
    iniT=${JRC2018_Unisexgen1CROPPED}
    
    echo "+----------------------------------------------------------------------+"
    echo "| Running CMTK warping"
    echo "| $CMTK/warp --threads $NSLOTS -o $registered_warp_xform --grid-spacing 80 --exploration 30 --coarsest 4 --accuracy 0.8 --refine 4 --energy-weight 1e-1 --initial $registered_affine_xform $iniT $gloval_nc82_nrrd"
    echo "+----------------------------------------------------------------------+"
    START=`date '+%F %T'`
    $CMTK/warp --threads $NSLOTS -o $registered_warp_xform --grid-spacing 80 --fast --exploration 26 --coarsest 8 --accuracy 0.8 --refine 4 --energy-weight 1e-1 --ic-weight 0 --initial $registered_affine_xform $iniT $gloval_nc82_nrrd
    STOP=`date '+%F %T'`
    if [[ ! -e $registered_warp_xform ]]; then
        echo -e "Error: CMTK warping failed"
        exit -1
    fi
    echo "cmtk_warping start: $START"
    echo "cmtk_warping stop: $STOP"
fi

rm $JRC2018_Unisexgen1CROPPED

echo " "
echo "+----------------------------------------------------------------------+"
echo "| 12-bit conversion"
echo "| $FIJI -macro $TWELVEBITCONV \"${OUTPUT}/,${InputName}_01.nrrd,${gloval_nc82_nrrd}\""
echo "+----------------------------------------------------------------------+"
$FIJI --headless -macro $TWELVEBITCONV "${OUTPUT}/,${InputName}_01.nrrd,${gloval_nc82_nrrd}"

########################################################################################################
# JFRC2018 Unisex High-resolution (for color depth search) reformat
########################################################################################################

banner "JFRC2018 Unisex High-resolution (for color depth search)"
sig="${OUTPUT}/${InputName}_U_20x_HR"
DEFFIELD=${registered_warp_xform}

TEMPLATE="${TemplatesDir}/JRC2018_UNISEX_20x_HR.nrrd"

gsig="${OUTPUT}/${InputName}"

reformatAll $gsig $TEMPLATE $DEFFIELD $sig RAWOUT
scoreGen "${sig}_01.nrrd" ${TEMPLATE} "score2018"

# Generate MIPs
MIPS_OUTPUT=${MIPS_OUTPUT:-"${OUTPUT}/MIP"}
generateAllMIPs ${OUTPUT} ${sig} ${MIPS_OUTPUT}

cp $OUTPUT/*.{png,jpg,txt,nrrd} $DEBUG_DIR
cp -R $OUTPUT/*.xform $DEBUG_DIR
cp $OUTPUT/*.property $FINALOUTPUT
cp $OUTPUT/*.nrrd $FINALOUTPUT
cp -a $MIPS_OUTPUT $FINALOUTPUT

echo "$0 done"
