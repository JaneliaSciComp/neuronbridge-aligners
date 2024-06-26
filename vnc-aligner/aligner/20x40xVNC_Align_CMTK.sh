#!/bin/bash
#
# 20x 40x VNC aligner by Hideo Otsuna
#

InputFilePath=$1
NSLOTS=$2
#nc82decision (reference channel) can be one of: "Signal_amount","ch1","ch2","ch3","ch4"
nc82decision=$3
FINALOUTPUT=$4
returnedErrorFilename=$5

InputFileName=$(basename $InputFilePath)
# final output name is the filename without extension
InputName=${InputFileName%.*} # final output name is the filename without extension
InputFileParentPath=$(dirname ${InputFilePath})

WORKING_DIR=${WORKING_DIR:-"${InputFileParentPath}/${InputName}_TMP"}
DEBUG_DIR="${WORKING_DIR}/Debug"
OUTPUT="${WORKING_DIR}/Output"
FINALOUTPUT=${FINALOUTPUT:-"${WORKING_DIR}/FinalOutputs"}

# Tools
CMTK_HOME=${CMTK_HOME:-"/opt/CMTK"}
CMTK=${CMTK_HOME}/bin
FIJI=/opt/Fiji/ImageJ-linux64
Vaa3D=/opt/Vaa3D/vaa3d
MACRO_DIR=/opt/aligner/fiji_macros

GENDER_TEMPLATE_SELECTOR="u"
objective="40x"

NRRDCONV="${MACRO_DIR}/nrrd2v3draw_MCFO.ijm"
PREPROCIMG="${MACRO_DIR}/VNC_preImageProcessing_Pipeline_07_29_2022.ijm"
NRRDCOMP="$MACRO_DIR/nrrd_compression.ijm"
 
export CMTK_WRITE_UNCOMPRESSED=1

# "-------------------Template----------------------"
MIP_TEMPLATE_DIR=${MIP_TEMPLATE_DIR:-"/data/alignment_templates"}
ALIGN_TEMPLATE_DIR=${ALIGN_TEMPLATE_DIR:-"/data/vnc-templates"}

TemplatesDir=`realpath ${ALIGN_TEMPLATE_DIR}`
MIPTemplatesDir=`realpath ${MIP_TEMPLATE_DIR}`

JRC2018_VNC_Unisex1micron="$TemplatesDir/JRC2018_VNC_UNISEX_1micron.nrrd"

memResource=${ALIGNMENT_MEMORY:-"2G"}
HEADLESS_FIJI_FLAG=${HEADLESS_FIJI_FLAG-"--headless"}
FIJI_OPTS="${HEADLESS_FIJI_FLAG} --ij2 --mem ${memResource}"

TEMPLATE_SELECTOR=1
if [[ ${TEMPLATE_SELECTOR} == 1 ]]; then
    TEMPNAME="JRC2018_VNC_UNISEX_447_G15.nrrd"
elif [[ $TEMPLATE_SELECTOR == 2 ]]; then
    TEMPNAME="JRC2018_VNC_UNISEX_63x_lowG.nrrd"
elif [[ $TEMPLATE_SELECTOR == 3 ]]; then
    TEMPNAME="RC2018_VNC_FEMALE_447_G15.nrrd"
elif [[ $TEMPLATE_SELECTOR == 4 ]]; then
    TEMPNAME="JRC2018_VNC_MALE_447_G15.nrrd"
fi

TARGET_TEMPLATE="$TemplatesDir/${TEMPNAME}"

echo "TEMPNAME; "$TEMPNAME

# For Score ########################################
if [[ $GENDER_TEMPLATE_SELECTOR =~ "m" ]]; then
    # male fly vnc
    Tfile=${TemplatesDir}"/MaleVNC2017.nrrd"
    POSTSCOREMASK="${MACRO_DIR}/For_Score/Mask_Male_VNC.nrrd"
elif [[ $GENDER_TEMPLATE_SELECTOR =~ "f" ]]; then
    # female fly vnc
    Tfile="${TemplatesDir}/FemaleVNCSymmetric2017.nrrd"
    POSTSCOREMASK="${MACRO_DIR}/For_Score/flyVNCtemplate20xA_CLAHE_MASK2nd.nrrd"
else
    # unisex fly vnc
    Tfile=${TemplatesDir}"/FemaleVNCSymmetric2017.nrrd"
    POSTSCOREMASK="${MACRO_DIR}/For_Score/JRC2018_VNC_UNISEX_447_3DMASK.nrrd"
fi

POSTSCORE="${MACRO_DIR}/Score_Generator_Cluster.ijm"
MIPGENERATION="${MACRO_DIR}/Color_Depth_MIP_batch_0404_2019_For_Pipeline_packbits.ijm"

#
# Reverse a stack in some dimension
# The third argument can be "xflip", "yflip", or "zflip"
#
function flip() {
    local _input="$1"
    local _output="$2"
    local _op="$3"
    if [[ -e $_output ]]; then
        echo "Already exists: $_output"
    else
        message " Flipping $_input with $_op"
        $Vaa3D -x ireg -f $_op -i $_input -o $_output
        echo ""
    fi
}

# Alignment score generation
function scoreGen() {
	local _outname="$1"
	local _scoretemp="$2"
	local _result_var="$3"
	
	local tempfilename=`basename $_scoretemp`
	local tempname=${tempfilename%%.*}
	local scorepath="$OUTPUT/${tempname}_Score.property"
	
	if [[ -e ${scorepath} ]]; then
	    echo "Already exists: $scorepath"
	else
	    echo "+---------------------------------------------------------------------------------------+"
	    echo "| Running Score generation"
	    echo "| $FIJI ${FIJI_OPTS} -macro ${POSTSCORE} ${OUTPUT}/,${_outname},${NSLOTS},${_scoretemp}"
        echo "+---------------------------------------------------------------------------------------+"
    
        START=`date '+%F %T'`
        # Expect to take far less than 1 hour
	    # Alignment Score generation:ZNCC, does not need Xvfb
	
	    $FIJI ${FIJI_OPTS} -macro ${POSTSCORE} ${OUTPUT}/,${_outname},${NSLOTS},${_scoretemp}
	    STOP=`date '+%F %T'`

	    echo "ZNCC JRC2018 score generation start: $START"
	    echo "ZNCC JRC2018 score generation stop: $STOP"
	fi
}

# Reformat a single NRRD file to the target deformation field
function reformat() {
    local _gsig="$1"
    local _TEMP="$2"
    local _DEFFIELD="$3"
    local _sig="$4"
    local _channel="$5"
    local _result_var="$6"
    local _opts="$7"

    if [[ -e $_sig ]]; then
        echo "Already exists: $_sig"
    else
        echo "--------------"
        echo "Running CMTK reformatting on channel $_channel"
        echo "$CMTK/reformatx --threads $NSLOTS -o $_sig $_opts --floating $_gsig $_TEMP $_DEFFIELD"
        START=`date '+%F %T'`
        $CMTK/reformatx --threads $NSLOTS -o "$_sig" $_opts --floating $_gsig $_TEMP $_DEFFIELD
        STOP=`date '+%F %T'`

        $FIJI ${FIJI_OPTS} -macro $NRRDCOMP "$_sig"

        if [[ ! -e $_sig ]]; then
            echo -e "Error: CMTK reformatting signal failed"
            exit -1
        fi

        echo "--------------"
        echo "cmtk_reformatting $TSTRING $_channel start: $START"
        echo "cmtk_reformatting $TSTRING $_channel stop: $STOP"
        echo " "
    fi
    eval $_result_var="'$_sig'"
}

# Reformat all the channels to the same template
function reformatAll() {
    local _gsig="$1"
    local _TEMP="$2"
    local _DEFFIELD="$3"
    local _sig="$4"
    local _result_var="$5"
    local _opts="$6"

    RAWOUT="${_sig}.v3draw" # Raw output file combining all the aligned channels
    RAWCONVPARAM=$RAWOUT
    RAWCONVSUFFIX=""

    # Reformat each channel
    for ((i=1; i<=4; i++)); do
        GLOBAL_NRRD="${_gsig}_0${i}.nrrd"
	
        if [[ -e $GLOBAL_NRRD ]]; then
            OUTPUT_NRRD="${_sig}_0${i}.nrrd"
            reformat "$GLOBAL_NRRD" "$_TEMP" "$_DEFFIELD" "$OUTPUT_NRRD" "$i" "ignore" "$opts"
        fi
	done
}

function generateAllMIPs() {
    local _sigDir=$1
    local _fullSigName=$2
    local _mipsOutput=$3
    # generate MIPs for all signal channels ...
    echo "Generate MIPs for all ${_fullSigName} signal channels to ${_mipsOutput}"

    for ((ii=1; ii<=4; ii++)); do
        if [[ -e "${_fullSigName}_0${ii}.nrrd" ]]; then
            mipCmdArgs="${_sigDir}/,${_fullSigName}_0${ii}.nrrd,${_mipsOutput}/,${MIPTemplatesDir}/,1.1,false,${NSLOTS}"
            mipsCmd="$FIJI ${FIJI_OPTS} -macro ${MIPGENERATION} ${mipCmdArgs}"
            echo "Generate MIPS for channel ${ii}: ${mipsCmd}"
            ${mipsCmd}
            echo "Finished generating MIPS for channel ${ii}"
        fi
    done
    echo "Finished MIPs generation for all signal channels"
}

# write output properties for JACS
function writeProperties() {
    local _raw_aligned="$1"
    local _raw_aligned_neurons="$2"
    local _alignment_space="$3"
    local _objective="$4"
    local _voxel_size="$5"
    local _image_size="$6"
    local _ncc_score="$7"
    local _pearson_coeff="$8"
    local _bridged_from="$9"

    raw_filename=`basename ${_raw_aligned}`
    prefix=${raw_filename%%.*}

    if [[ -f "$_raw_aligned" ]]; then
        META="${OUTPUT}/${prefix}.properties"
        echo "alignment.stack.filename="${raw_filename} > $META
        echo "alignment.image.area=VNC" >> $META
        echo "alignment.image.channels=$INPUT1_CHANNELS" >> $META
        echo "alignment.image.refchan=$INPUT1_REF" >> $META
        echo "alignment.space.name=$_alignment_space" >> $META
        echo "alignment.image.size=$_image_size" >> $META
        echo "alignment.resolution.voxels=$_voxel_size" >> $META
        echo "alignment.objective=$_objective" >> $META
        if [[ ! -z "$_ncc_score" ]]; then
            echo "alignment.quality.score.ncc=$_ncc_score" >> $META
        fi
        if [[ ! -z "$_pearson_coeff" ]]; then
            echo "alignment.object.pearson.coefficient=$_pearson_coeff" >> $META
        fi
        if [[ -e $_raw_aligned_neurons ]]; then
            raw_neurons_filename=`basename ${_raw_aligned_neurons}`
            echo "neuron.masks.filename=$raw_neurons_filename" >> $META
        fi
        if [[ ! -z "$_bridged_from" ]]; then
            echo "alignment.bridged.from=$_bridged_from" >> $META
        fi
    else
        echo "Output file does not exist: $_raw_aligned"
        exit 1
    fi
}

# write output properties for JACS
function writeErrorProperties() {
    local _prefix="$1"
    local _alignment_space="$2"
    local _objective="$3"
    local _error="$4"

    META="${FINALOUTPUT}/${_prefix}.properties"
    echo "alignment.error="${_error} > $META
    echo "alignment.image.area=VNC" >> $META
    echo "alignment.space.name=$_alignment_space" >> $META
    echo "alignment.objective=$_objective" >> $META
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

if [[ ! -f ${InputFilePath} ]]; then
    # input file not found
    echo "Input file '${InputFilePath}' not found" > ${returnedErrorFilename}
    exit 1
elif [[ -f ${InputFilePath} && ! -s ${InputFilePath} ]]; then
    # the file exists but is empty
    echo "Input file ('${InputFilePath}') found but is empty" > ${returnedErrorFilename}
    exit 1
fi

if [[ ${GENDER_TEMPLATE_SELECTOR} == "f" ]]; then
    genderT="FEMALE"
    oldVNC=$TemplatesDir"/FemaleVNCSymmetric2017.nrrd"
    reformat_JRC2018_to_oldVNC=$TemplatesDir"/Deformation_Fields/oldFemale_JRC2018_VNC_FEMALE"
    OLDSPACE="FemaleVNCSymmetric2017_20x"
    iniT=${JRC2018_VNC_Female}
    OLDVOXELS="0.4612588x0.4612588x0.7"
elif [[ $GENDER_TEMPLATE_SELECTOR == "m" ]]; then
    genderT="MALE"
    oldVNC=$TemplatesDir"/MaleVNC2017.nrrd"
    reformat_JRC2018_to_oldVNC=$TemplatesDir"/Deformation_Fields/oldMale_JRC2018_VNC_MALE"
    OLDSPACE="MaleVNC2016_20x"
    iniT=$JRC2018_VNC_Male
    OLDVOXELS="0.4611222x0.4611222x0.7"
elif [[ $GENDER_TEMPLATE_SELECTOR == "u" ]]; then
    genderT="UNISEX"
    iniT=${JRC2018_VNC_Unisex1micron}
else
    echo "ERROR: invalid gender: $GENDER_TEMPLATE_SELECTOR"
    exit 1
fi

filename="PRE_PROCESSED_"${genderT}

echo "GENDER_TEMPLATE_SELECTOR; "$GENDER_TEMPLATE_SELECTOR
echo "genderT; "$genderT
echo "oldVNC; "$oldVNC
echo "OLDSPACE; "$OLDSPACE
echo "reformat_JRC2018_to_oldVNC; "$reformat_JRC2018_to_oldVNC

# "-------------------Global aligned files----------------------"
gloval_nc82_nrrd=$OUTPUT"/"$filename"_01.nrrd"

# "-------------------Deformation fields----------------------"
registered_initial_xform=$OUTPUT"/initial.xform"
registered_affine_xform=$OUTPUT"/affine.xform"
registered_warp_xform=$OUTPUT"/warp.xform"

reformat_JRC2018_to_Uni="$TemplatesDir/Deformation_Fields/JRC2018_VNC_Unisex_JRC2018_$genderT"

LOGFILE="${OUTPUT}/VNC_pre_aligner_log.txt"

SHAPE_ANALYSIS="true"
if [[ $SKIP_PREALIGNER == "true" ]]; then
    echo "SKIP_PREALIGNER is $SKIP_PREALIGNER, skipping shape analysis"
    SHAPE_ANALYSIS="false"
fi
echo "+---------------------------------------------------------------------------------------+"
echo "| Running Otsuna preprocessing step                                                     |"
echo "| $FIJI ${FIJI_OPTS} -macro ${PREPROCIMG} \"${OUTPUT}/,${filename},${TemplatesDir}/,${InputFilePath},ssr,${GENDER_TEMPLATE_SELECTOR},NULL,${NSLOTS},${SHAPE_ANALYSIS},${nc82decision}\" >$DEBUG_DIR/preproc.log 2>&1 |"
echo "+---------------------------------------------------------------------------------------+"
START=`date '+%F %T'`
echo "Otsuna preprocessing start: $START"
# Expect to take far less than 1 hour
$FIJI ${FIJI_OPTS} -macro ${PREPROCIMG} "${OUTPUT}/,${filename},${TemplatesDir}/,${InputFilePath},ssr,${GENDER_TEMPLATE_SELECTOR},NULL,${NSLOTS},${SHAPE_ANALYSIS},${nc82decision}" >$DEBUG_DIR/preproc.log 2>&1
preprocessExitCode=$?

STOP=`date '+%F %T'`

echo "Otsuna preprocessing stop: $STOP with exit code ${preprocessExitCode}"
# check for prealigner errors

cp $LOGFILE $DEBUG_DIR
if [[ ${preprocessExitCode} -ne 0 ]] ; then
    # dump preprocessing log
    echo "Dump Preprocessing Log because it exited with code ${preprocessExitCode}"
    cat "$DEBUG_DIR/preproc.log"
fi

echo "Check preprocessing log for errors"
if [[ -e "$OUTPUT/bad_shape.txt" ]] ; then
    echo "Shape problems found"
    cat "$OUTPUT/bad_shape.txt"
else
    echo "Did not identify any shape problem"
fi

CoreDumpError=`grep SIGSEGV $DEBUG_DIR/preproc.log`
PreAlignerError=`grep "PreAlignerError: " $LOGFILE | head -n1 | sed "s/PreAlignerError: //"`
MemoryError=`grep -i "Cannot allocate memory" $LOGFILE | head -n1`
OutOfMemoryError=`grep -i "out of memory" $LOGFILE | head -n1`

if [[ ! -z "${CoreDumpError}" ]] ; then
    ALIGNMENT_ERROR="Preprocessing failed with a fatal error"
elif [[ ! -z "${PreAlignerError}" ]]; then
    ALIGNMENT_ERROR="Pre-aligner rejection: $PreAlignerError"
elif [[ ! -z "${MemoryError}" || ! -z "${OutOfMemoryError}" ]] ; then
    ALIGNMENT_ERROR="Out of memory error";
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

echo "iniT; "$iniT
echo "gloval_nc82_nrrd; "$gloval_nc82_nrrd
echo ""

# -------------------------------------------------------------------------------------------
if [[ -e $registered_initial_xform ]]; then
    echo "Already exists: $registered_initial_xform"
else
    echo "+---------------------------------------------------------------------------------------+"
    echo "| Running CMTK/make_initial_affine"
    echo "| $CMTK/make_initial_affine --threads $NSLOTS --principal_axes $iniT $gloval_nc82_nrrd $registered_initial_xform"
    echo "+---------------------------------------------------------------------------------------+"
    START=`date '+%F %T'`
    $CMTK/make_initial_affine --threads $NSLOTS --principal_axes $iniT $gloval_nc82_nrrd $registered_initial_xform
    STOP=`date '+%F %T'`
    if [[ ! -e $registered_initial_xform ]]; then
        echo -e "Error: CMTK make initial affine failed"
        exit -1
    fi
    echo "cmtk_initial_affine start: $START"
    echo "cmtk_initial_affine stop: $STOP"

    echo " "
    echo "+----------------------------------------------------------------------+"
    echo "| Running CMTK registration"
    echo "| $CMTK/registration --threads $NSLOTS --initial $registered_initial_xform --dofs 6,9 --auto-multi-levels 4 --accuracy 0.8 -o $registered_affine_xform $iniT $gloval_nc82_nrrd "
    echo "+----------------------------------------------------------------------+"
    START=`date '+%F %T'`
    $CMTK/registration --threads $NSLOTS --initial $registered_initial_xform --dofs 6,9 --accuracy 0.8 -o $registered_affine_xform $iniT $gloval_nc82_nrrd
    STOP=`date '+%F %T'`
    if [[ ! -e $registered_affine_xform ]]; then
        echo -e "Error: CMTK registration failed"
        exit -1
    fi
    echo "cmtk_registration start: $START"
    echo "cmtk_registration stop: $STOP"
fi

# CMTK warping
if [[ -e $registered_warp_xform ]]; then
    echo "Already exists: $registered_warp_xform"
else
    echo " "
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

FLIP_NEURON=""
DEFFIELD="$registered_warp_xform"
sig="$OUTPUT/${InputName}"
TEMP=$TARGET_TEMPLATE
gsig="$OUTPUT/$filename"

echo "reformat output; ${sig}_01.nrrd"

if [[ ! -e "${sig}_01.nrrd" ]]; then
    ########################################################################################################
    # JRC2018 unisex reformat
    ########################################################################################################

    banner "JRC2018 unisex reformat"
    reformatAll "$gsig" "$TARGET_TEMPLATE" "$DEFFIELD" "$sig" "RAWOUT"
fi

echo "Score log: ${OUTPUT}/${TARGET_TEMPLATE%.*}_Score.property"
scoreGen "${sig}_01.nrrd" ${TARGET_TEMPLATE} "score2018"

# Generate MIPs
MIPS_OUTPUT=${MIPS_OUTPUT:-"${OUTPUT}/MIP"}
generateAllMIPs ${OUTPUT} ${sig} ${MIPS_OUTPUT}

for fin in ${OUTPUT}/*.avi; do
    fout=${fin%.avi}.mp4
    echo "ffmpeg -y -r 7 -i ${fin} -vcodec libx264 -b:v 2000000 -preset slow -tune film -pix_fmt yuv420p ${fout}"
    ffmpeg -y -r 7 -i \
           "$fin" -vcodec libx264 \
           -b:v 2000000 -preset slow \
           -tune film -pix_fmt yuv420p "$fout" && \
    rm $fin
done

cp -R $OUTPUT/*.xform $DEBUG_DIR
find $OUTPUT \
  -maxdepth 1 \
  -regextype posix-extended \
  -regex ".*\.(png|jpg|txt|log|nrrd)" \
  -exec cp {} $DEBUG_DIR \;

echo copy {avi,property,nrrd,jpg,png,mp4,txt} to $FINALOUTPUT
find $OUTPUT \
  -maxdepth 1 \
  -regextype posix-extended \
  -regex ".*\.(avi|property|nrrd|jpg|png|mp4|txt|yaml)" \
  -exec cp {} $FINALOUTPUT \;

echo copy $MIPS_OUTPUT $FINALOUTPUT
cp -a $MIPS_OUTPUT $FINALOUTPUT

echo "$0 done"
