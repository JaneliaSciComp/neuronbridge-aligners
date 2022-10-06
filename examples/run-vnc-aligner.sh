localip=$(ifconfig en0 | grep inet | awk '$1=="inet" {print $2}')

xhost + $localip

FB_MODE_PARAM="-e DISPLAY=$localip:0"

DATA_FILE=JRC_SS04989-20160318_24_A3-f_40x.h5j

LOCAL_DATA=local/testData
INPUT="/data/vncData/${DATA_FILE}"
OUTPUT="/data/vncOutput/${DATA_FILE%.*}"

docker run \
       -v $PWD/${LOCAL_DATA}:/data \
       -v $PWD/local/scratch:/scratch \
       -it \
       $FB_MODE_PARAM \
       -e TMP=/scratch \
       registry.int.janelia.org/neuronbridge/vnc-aligner \
       /opt/aligner-scripts/run_aligner.sh \
       -debug \
       --miptemplatedir /data/templates \
       --vncaligntemplatedir /data/vnc-templates \
       -i $INPUT \
       -o $OUTPUT \
       $*