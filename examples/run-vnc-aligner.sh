localip=$(ifconfig en0 | grep inet | awk '$1=="inet" {print $2}')

xhost + $localip

FB_MODE_PARAM="-e DISPLAY=$localip:0"

if [ "$#" -ge 1 ]; then
    DATA_FILE=$1
    shift
else
    DATA_FILE=JRC_SS04989-20160318_24_A3-f_40x.h5j
fi

LOCAL_DATA=local/testData
INPUT="/data/vncData/${DATA_FILE}"
OUTPUT="/data/vncOutput/${DATA_FILE%.*}"

PLATFORM_ARG="--platform=linux/x86_64"

docker run \
       -v $PWD/${LOCAL_DATA}:/data \
       -v $PWD/local/scratch:/scratch \
       -it \
       $FB_MODE_PARAM \
       ${PLATFORM_ARG} \
       -e ALIGNMENT_MEMORY=16G \
       -e TMP=/scratch \
       -e TMPDIR=/scratch \
       janeliascicomp/neuronbridge-vncaligner:1.0 \
       /opt/aligner-scripts/run_aligner.sh \
       -debug \
       --miptemplatedir /data/templates \
       --vncaligntemplatedir /data/vnc-templates \
       -i $INPUT \
       -o $OUTPUT \
       $*
