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
      -e FB_MODE=xvfb \
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
    localips=$(ifconfig | grep inet | awk '$1=="inet" {print $2}')
    for localip in $localips; do
        echo $localip
        xhost + $localip
    done
    FB_MODE=${FB_MODE:-"xvfb"}
    FB_MODE_PARAM="-e FB_MODE=${FB_MODE} -e DISPLAY=host.docker.internal:0"
fi

if [ "$#" -ge 1 ]; then
    DATA_FILE=$1
    shift
else
    DATA_FILE=Ahana.zip
fi

INPUT="/data/brainData/${DATA_FILE}"
OUTPUT="/data/brainOutput/${DATA_FILE%.*}"

XYRES=0.55
ZRES=1
FORCE=false

docker run \
       -v $PWD/local/testData:/data \
       -v $PWD/local/scratch:/scratch \
       -it \
       ${FB_MODE_PARAM} \
       -e TMP=/scratch \
       -e TMPDIR=/scratch \
       -e PREALIGN_TIMEOUT=9000 \
       -e PREALIGN_CHECKINTERVAL=10 \
       -e ALIGNMENT_MEMORY=16G \
       janeliascicomp/neuronbridge-brainaligner:1.1 \
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
