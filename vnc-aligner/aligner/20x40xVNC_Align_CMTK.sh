#!/bin/bash
#
# 20x 40x VNC aligner by Hideo Otsuna
#
testmode=0

if [[ $testmode != 1 ]]; then
  DIR=$(cd "$(dirname "$0")"; pwd)
  . $DIR/common.sh
  SKIP_PREALIGNER="false"
  parseParameters "$@"
  nc82decision="Signal_amount"


  # Tools
  CMTK=/opt/CMTK/bin
  FIJI=/opt/Fiji/ImageJ-linux64
  Vaa3D=/opt/Vaa3D/vaa3d
  MACRO_DIR=/opt/aligner/fiji_macros

  # Fiji macros
  NRRDCONV=$MACRO_DIR"/nrrd2v3draw.ijm"
  PREPROCIMG=${MACRO_DIR}"VNC_preImageProcessing_Pipeline_07_29_2022.ijm"
  TWELVEBITCONV=$MACRO_DIR"/12bit_Conversion.ijm"
NRRDCOMP=$MACRO_DIR"/nrrd_compression.ijm"

  Path=$INPUT1_FILE
  objective=$INPUT1_OBJECTIVE
  OUTPUT=$WORK_DIR"/Output"
  FINALOUTPUT=$WORK_DIR"/FinalOutputs"
  TempDir=${MACRO_DIR}"Template"
  MIPTempDir=${MACRO_DIR}"Template_MIP"

  DEBUG_DIR=$FINALOUTPUT"/debug"
  mkdir -p $DEBUG_DIR
  echo "DEBUG_DIR: $DEBUG_DIR"
fi

echo "$testmode; "$testmode
# For TEST ############################################
if [[ $testmode == "1" ]]; then
    echo "Test mode"

    InputFilePath=$1
    NSLOTS=$2
    OUTPUTORI=$3
    nc82decision="Signal_amount"

    end=${InputFilePath##*/}
    num1=$((${#InputFilePath} - ${#end}))

    OUTPUTNAME=${InputFilePath#*/}
    OUTPUTNAME=${OUTPUTNAME#*/}
    OUTPUTNAME=${OUTPUTNAME#*/}
    OUTPUTNAME=${OUTPUTNAME#*/}
    OUTPUTNAME=${OUTPUTNAME#*/}
    OUTPUTNAME=${OUTPUTNAME#*/}
    OUTPUTNAME=${OUTPUTNAME#*/}
    OUTPUTNAME=${OUTPUTNAME#*/}
    OUTPUTNAME=${OUTPUTNAME#*/}
    OUTPUTNAME=${OUTPUTNAME#*/}
    OUTPUTNAME=${OUTPUTNAME#*/}
    OUTPUTNAME=${OUTPUTNAME#*/}
    OUTPUTNAME=${OUTPUTNAME#*/}
    OUTPUTNAME=${OUTPUTNAME#*/}

    echo "OUTPUTNAME; "${OUTPUTNAME%.*}

    WORK_DIRPRE=${InputFilePath:0:num1-1}
    WORK_DIR=${WORK_DIRPRE}"/"${OUTPUTNAME%.*}

    if [[ ! -d ${OUTPUTORI} ]]; then
        mkdir ${OUTPUTORI}
    fi

    OUTPUT=${OUTPUTORI}"/"${OUTPUTNAME%.*}

    ####### tools location setting #######################################################
    MACRO_DIR="/Users/otsunah/test/VNC_aligner_local_ver/"
    FIJI=/Applications/Fiji_copy.app/Contents/MacOS/ImageJ-macosx
    CMTK=/Applications/Fiji_copy.app/bin/cmtk

    TEMPNUMBER=1
    echo "TEMPNUMBER; "$TEMPNUMBER

    INPUT1_GENDER="u"
    objective="40x"

    TempDir=${MACRO_DIR}"Template"
    MIPTempDir=${MACRO_DIR}"Template_MIP"
    NRRDCONV=${MACRO_DIR}"nrrd2v3draw_MCFO.ijm"
    PREPROCIMG=${MACRO_DIR}"VNC_preImageProcessing_Pipeline_07_29_2022.ijm"
    NRRDCOMP=$MACRO_DIR"/nrrd_compression.ijm"
 
fi

export CMTK_WRITE_UNCOMPRESSED=1

# "-------------------Template----------------------"
JRC2018_VNC_Unisex1micron=$TempDir"/JRC2018_VNC_UNISEX_1micron.nrrd"

if [[ ${TEMPNUMBER} == 1 ]]; then
    TEMPNAME="JRC2018_VNC_UNISEX_447_G15.nrrd"
elif [[ $TEMPNUMBER == 2 ]]; then
    TEMPNAME="JRC2018_VNC_UNISEX_63x_lowG.nrrd"
elif [[ $TEMPNUMBER == 3 ]]; then
    TEMPNAME="RC2018_VNC_FEMALE_447_G15.nrrd"
elif [[ $TEMPNUMBER == 4 ]]; then
    TEMPNAME="JRC2018_VNC_MALE_447_G15.nrrd"
fi

TARGET_TEMPLATE=$TempDir"/${TEMPNAME}"

echo "TEMPNAME; "$TEMPNAME


# For Score ########################################
if [[ $INPUT1_GENDER =~ "m" ]]; then
    # male fly vnc
    Tfile=${TempDir}"/MaleVNC2017.nrrd"
    POSTSCOREMASK=$MACRO_DIR"/For_Score/Mask_Male_VNC.nrrd"
elif [[ $INPUT1_GENDER =~ "f" ]]; then
    # female fly vnc
    Tfile=${TempDir}"/FemaleVNCSymmetric2017.nrrd"
    POSTSCOREMASK=$MACRO_DIR"/For_Score/flyVNCtemplate20xA_CLAHE_MASK2nd.nrrd"
else
    # unisex fly vnc
    Tfile=${TempDir}"/FemaleVNCSymmetric2017.nrrd"
    POSTSCOREMASK=$MACRO_DIR"/For_Score/JRC2018_VNC_UNISEX_447_3DMASK.nrrd"
fi

POSTSCORE=${MACRO_DIR}"/Score_Generator_Cluster.ijm"
MIPGENERATION=${MACRO_DIR}"/Color_Depth_MIP_batch_0404_2019_For_Pipeline_packbits.ijm"

#
# Expand resolutions from TMOG
#
function expandRes() {
    local _res="$1"
    local _result_var="$2"
    if [[ $_res == "0.44" ]]; then
        result="0.4413373"
    elif [[ $_res == "0.52" ]]; then
        result="0.5189161"
    elif [[ $_res == "0.62" ]]; then
        result="0.621481"
    else
        result=$_res
    fi
    eval $_result_var="'$result'"
}

# Convert multiple NRRD files into a single v3draw file.
# Params for this function are the same as for the Fiji macro, a single parameter with comma-delimited file names:
#   "output.v3draw,input1.nrrd,input2.nrrd..."
function nrrd2Raw() {
    local _PARAMS="$1"
    OUTPUTRAW=${_PARAMS%%,*}
    if [[ -e $OUTPUTRAW ]]; then
        echo "Already exists: $OUTPUTRAW"
    else
        TS=`date +%Y%m%d-%H%M%S`
        LOGFILE="$DEBUG_DIR/raw-${TS}.log"
        echo "+----------------------------------------------------------------------+"
        echo "| Running NRRD -> v3draw conversion"
        echo "| $FIJI --headless -macro $NRRDCONV $_PARAMS >$LOGFILE"
        echo "+----------------------------------------------------------------------+"
        START=`date '+%F %T'`
        $FIJI --headless -macro $NRRDCONV $_PARAMS >$LOGFILE 2>&1
        STOP=`date '+%F %T'`
        if [[ ! -e $OUTPUTRAW ]]; then
            echo -e "Error: NRRD -> raw conversion failed"
            exit -1
        fi
        echo "nrrd_raw_conversion start: $START"
        echo "nrrd_raw_conversion stop: $STOP"
    fi
}

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
        #---exe---#
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
	
	tempfilename=`basename $_scoretemp`
	tempname=${tempfilename%%.*}
	scorepath="$OUTPUT/${tempname}_Score.property"
	
	if [[ -e ${scorepath} ]]; then
	echo "Already exists: $scorepath"
	else
	echo "+---------------------------------------------------------------------------------------+"
	echo "| Running Score generation"
	echo "| $FIJI --headless -macro $POSTSCORE $OUTPUT/,$_outname,$NSLOTS,$_scoretemp"
	echo "+---------------------------------------------------------------------------------------+"
	
	START=`date '+%F %T'`
	# Expect to take far less than 1 hour
	# Alignment Score generation:ZNCC, does not need Xvfb
	
	$FIJI --headless -macro ${POSTSCORE} $OUTPUT/,$_outname,$NSLOTS,$_scoretemp
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

        $FIJI --headless -macro $NRRDCOMP "$_sig"

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

if [[ ! -d $OUTPUT ]]; then
    mkdir $OUTPUT
fi

if [[ ! -d $FINALOUTPUT ]]; then
    mkdir $FINALOUTPUT
fi

if [[ ! -e $PREPROCIMG ]]; then
    echo "Preprocess macro could not be found at $PREPROCIMG"
    exit 1
fi

if [[ ! -e $FIJI ]]; then
    echo "Fiji cannot be found at $FIJI"
    exit 1
fi


if [[ ${INPUT1_GENDER} == "f" ]]; then
    genderT="FEMALE"
    oldVNC=$TempDir"/FemaleVNCSymmetric2017.nrrd"
    reformat_JRC2018_to_oldVNC=$TempDir"/Deformation_Fields/oldFemale_JRC2018_VNC_FEMALE"
    OLDSPACE="FemaleVNCSymmetric2017_20x"
    iniT=${JRC2018_VNC_Female}
    OLDVOXELS="0.4612588x0.4612588x0.7"
elif [[ $INPUT1_GENDER == "m" ]]; then
    genderT="MALE"
    oldVNC=$TempDir"/MaleVNC2017.nrrd"
    reformat_JRC2018_to_oldVNC=$TempDir"/Deformation_Fields/oldMale_JRC2018_VNC_MALE"
    OLDSPACE="MaleVNC2016_20x"
    iniT=$JRC2018_VNC_Male
    OLDVOXELS="0.4611222x0.4611222x0.7"
elif [[ $INPUT1_GENDER == "u" ]]; then
    genderT="UNISEX"
    iniT=${JRC2018_VNC_Unisex1micron}
else
    echo "ERROR: invalid gender: $INPUT1_GENDER"
    exit 1
fi

filename="PRE_PROCESSED_"${genderT}

echo "INPUT1_GENDER; "$INPUT1_GENDER
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

reformat_JRC2018_to_Uni=$TempDir"/Deformation_Fields/JRC2018_VNC_Unisex_JRC2018_"$genderT

LOGFILE="${OUTPUT}/VNC_pre_aligner_log.txt"
if [[ -e $LOGFILE ]]; then
    echo "Already exists: $LOGFILE"
else
    SHAPE_ANALYSIS="true"
    if [[ $SKIP_PREALIGNER == "true" ]]; then
        echo "SKIP_PREALIGNER is $SKIP_PREALIGNER, skipping shape analysis"
        SHAPE_ANALYSIS="false"
    fi
    echo "+---------------------------------------------------------------------------------------+"
    echo "| Running Otsuna preprocessing step                                                     |"
    echo "| $FIJI -macro $PREPROCIMG \"$OUTPUT/,$filename,$TempDir,$InputFilePath,ssr,$INPUT1_GENDER,NULL,$NSLOTS,$SHAPE_ANALYSIS\" >$DEBUG_DIR/preproc.log 2>&1 |"
    echo "+---------------------------------------------------------------------------------------+"
    START=`date '+%F %T'`
    # Expect to take far less than 1 hour

    if [[ $testmode != 1 ]]; then
        $FIJI -macro $PREPROCIMG "$OUTPUT/,$filename,$TempDir/,$InputFilePath,ssr,$INPUT1_GENDER,NULL,$NSLOTS,${SHAPE_ANALYSIS},${nc82decision}" >$DEBUG_DIR/preproc.log 2>&1
    else
        $FIJI --headless -macro $PREPROCIMG "$OUTPUT/,${filename},$TempDir/,$InputFilePath,ssr,$INPUT1_GENDER,NULL,$NSLOTS,${SHAPE_ANALYSIS},${nc82decision}" 
    fi

    STOP=`date '+%F %T'`
    echo "Otsuna preprocessing start: $START"
    echo "Otsuna preprocessing stop: $STOP"
    # check for prealigner errors

    if [[ $testmode != 1 ]]; then
        cp $LOGFILE $DEBUG_DIR
        PreAlignerError=`grep "PreAlignerError: " $LOGFILE | head -n1 | sed "s/PreAlignerError: //"`
        if [[ ! -z "$PreAlignerError" ]]; then
            writeErrorProperties "PreAlignerError" "JRC2018_VNC_${genderT}" "$objective" "Pre-aligner rejection: $PreAlignerError"
            exit 0
        fi
    fi
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
fn=${OUTPUTNAME%.*}
sig=$OUTPUT"/"$fn
TEMP="$TARGET_TEMPLATE"
gsig=$OUTPUT"/"$filename

echo "reformat output; "${sig}"_01.nrrd"

if [[ ! -e ${sig}"_01.nrrd" ]]; then
    ########################################################################################################
    # JRC2018 unisex reformat
    ########################################################################################################

    banner "JRC2018 unisex reformat"
    reformatAll "$gsig" "$TARGET_TEMPLATE" "$DEFFIELD" "$sig" "RAWOUT"
fi

echo "score log; "${OUTPUT}"/Score_log_"${TARGET_TEMPLATE%.*}".txt"

if [[ ! -e ${OUTPUT}"/Score_log_"${TEMPNAME%.*}".txt" ]]; then
    scoreGen $sig"_01.nrrd" ${TARGET_TEMPLATE} "score2018"
fi

for ((ii=1; ii<=4; ii++)); do
    if [[ -e "${sig}_0${ii}.nrrd" ]]; then
        $FIJI --headless -macro ${MIPGENERATION} "${OUTPUT}/,${sig}_0"$ii".nrrd,${OUTPUTORI}/MIP/,${MIPTempDir}/,1.1,false,${NSLOTS}"
    fi
done

if [[ $testmode != 1 ]]; then
  writeProperties "$RAWOUT" "$FLIP_NEURON" "JRC2018_VNC_Unisex_40x_DS" "40x_DS" "0.461122x0.461122x0.70" "573x1119x219" "" "" "$main_aligned_file"
fi

#if [[ -e $sig"_01.nrrd" ]]; then
  #  rm $OUTPUT"/"$filename"_01.nrrd"
  #  rm $OUTPUT"/"$filename"_02.nrrd"
#fi


echo "$0 done"


