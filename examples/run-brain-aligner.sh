if [ $(uname) == 'Linux' ]; then
    echo "Detected Host System: Linux"
    # Setup xauth file location; Remove if exists
    echo "Setting up X11 forwarding for User: ${USER}"
    XTEMP=/tmp/.docker.xauth.${USER}
    if [ -e ${XTEMP} ]; then
        rm -f ${XTEMP}
    fi

    # Create new xauth file
    touch ${XTEMP}

    # modify xauth file
    xauth nlist $(hostname)/unix:${DISPLAY:1:1} | sed -e 's/^..../ffff/' | xauth -f ${XTEMP} nmerge -

    FB_MODE_PARAM="\
      -e FB_MODE=false \
      -e DISPLAY=$DISPLAY \
      -e QT_X11_NO_MITSHM=1 \
      -e XAUTHORITY=${XTEMP} \
      -v /tmp:/tmp \
      -v ${XTEMP}:${XTEMP} \
      --device=/dev/dri:/dev/dri \
      --net=host \
      "
elif [ $(uname) == 'Darwin' ]; then
    # XQuartz must be installed and under Preferences > Security 
    # both "Authenticate connections" and "Allow connections from network clients" must be ON
    echo "Detected Host System: OSX"
    localip=$(ifconfig en0 | grep inet | awk '$1=="inet" {print $2}')

    xhost + $localip

    FB_MODE_PARAM="-e FB_MODE=false -e DISPLAY=$localip:0"
fi


DATA_FILE=43LEXAGCaMP6s_for_nBLAST_0003.zip

INPUT="/data/${DATA_FILE}"
OUTPUT="/data/${DATA_FILE%.*}"

XYRES=0.55
ZREZ=1
FORCE=false

docker run \
       -v $PWD/local/testData:/data \
       -v $PWD/local/scratch:/scratch \
       -it \
       ${FB_MODE_PARAM} \
       -e TMP=/scratch \
       -e PREALIGN_TIMEOUT=3600 \
       -e PREALIGN_CHECKINTERVAL=10 \
       -e ALIGNMENT_MEMORY=10G \
       registry.int.janelia.org/neuronbridge/neuronbridge-brainaligner:1.0 \
       /opt/aligner-scripts/run_aligner.sh \
       -debug \
       --forceVxSize ${FORCE} \
       --xyres ${XYRES} \
       --zres ${ZRES} \
       --nslots 4 \
       --reference-channel Signal_amount \
       --comparison_alg Max \
       --templatedir /data/templates \
       -i $INPUT \
       -o $OUTPUT \
       $*
