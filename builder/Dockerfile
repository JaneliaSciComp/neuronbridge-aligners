FROM scientificlinux/sl:7 as builder

RUN yum group install -y "Development Tools" && \
    yum install -y git nasm \
                   wget tar unzip

WORKDIR /tmp

RUN mkdir ffmpeg-code && \
    cd ffmpeg-code && \
    git clone --branch "release/4.2" --depth 1 https://github.com/FFmpeg/FFmpeg.git .

ARG NCORES=5
RUN mkdir ffmpeg-build && \
    cd ffmpeg-build && \
    /tmp/ffmpeg-code/configure \
        --disable-doc \
        --disable-static \
        --enable-shared && \
    make -j ${NCORES}

WORKDIR /opt

# Download and Install Fiji
ARG FIJI_VERSION=20221111-1317
ENV FIJI_FILE=fiji-linux64.zip
ENV FIJI_DOWNLOAD_URL=https://downloads.imagej.net/fiji/archive/${FIJI_VERSION}/${FIJI_FILE}
ENV EXTTRACT_CMD="unzip"
RUN wget --no-check-certificate ${FIJI_DOWNLOAD_URL}
RUN ${EXTTRACT_CMD} $FIJI_FILE && \
    /bin/rm -rf ${FIJI_FILE} && \
    rm -rf Fiji && \
    mv Fiji.app Fiji

ARG CMTK_NAME=cmtk-20190116-sl7avx2
ARG CMTK_FILE=cmtk-20190116-sl7avx2.tgz

RUN wget https://github.com/JaneliaSciComp/tools-archive/releases/download/1.0.0/${CMTK_FILE} && \
    tar xvf ${CMTK_FILE} && \
    /bin/rm -f ${CMTK_FILE}
