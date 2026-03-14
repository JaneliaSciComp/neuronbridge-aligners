FROM oraclelinux:9
ARG TARGETPLATFORM

RUN dnf update -y && \
    dnf install -y epel-release && \
    dnf install --nogpgcheck -y https://download1.rpmfusion.org/free/el/rpmfusion-free-release-$(rpm -E %rhel).noarch.rpm && \
    dnf config-manager --set-enabled ol9_codeready_builder

RUN dnf install -y \
        net-tools \
        libX11-devel x265-devel \
        Xvfb \
        ImageMagick \
        tree jq bc

RUN dnf install -y python3-pip && \
    pip3 install --upgrade pip && \
    pip3 install yq

RUN echo "Installing S3 FUSE and AWS CLI"
RUN dnf install -y fuse3-devel s3fs-fuse \
        groff wget tar unzip less

WORKDIR /awsinstall
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
RUN unzip awscliv2.zip
RUN ./aws/install
RUN rm -rf aws*

WORKDIR /opt

# Prereqs for Fiji and CMTK
RUN dnf install -y \
        ffmpeg \
        mesa-libGLU libXtst-devel libXrender \
        fftw-libs-double

RUN echo "Installing Fiji"
ARG FIJI_VERSION=stable/20260307-1417
ENV FIJI_FILE=fiji-stable-linux64-jdk.zip
ENV FIJI_DOWNLOAD_URL=https://downloads.imagej.net/fiji/archive/${FIJI_VERSION}/${FIJI_FILE}
ENV EXTTRACT_CMD="unzip"
RUN wget --no-check-certificate ${FIJI_DOWNLOAD_URL}
RUN ${EXTTRACT_CMD} $FIJI_FILE && \
    /bin/rm -rf ${FIJI_FILE} && \
    rm -rf Fiji && \
    mv Fiji.app Fiji

RUN echo "Installing CMTK"

# Download AVX2 build for CMTK
ENV CMTK_NAME=cmtk-20190116-sl7avx2
ENV CMTK_FILE=cmtk-20190116-sl7avx2.tgz

RUN wget -q https://github.com/JaneliaSciComp/tools-archive/releases/download/1.0.0/${CMTK_FILE} && \
    tar xvf ${CMTK_FILE} && \
    /bin/rm -f ${CMTK_FILE} && \
    ln -s ${CMTK_NAME} CMTK

ENV CMTK_HOME=/opt/CMTK

ENV S3_TEMPLATES_MOUNTPOINT=/s3_alignment_templates

RUN mkdir -p ${S3_TEMPLATES_MOUNTPOINT}

ENV XVFB_HELPER_SCRIPTS_DIR=/opt/xvfb_helper_scripts
ENV FB_MODE=

COPY xvfb_helper_scripts ${XVFB_HELPER_SCRIPTS_DIR}

# copy alignment scripts
COPY aligner /opt/aligner
COPY scripts /opt/aligner-scripts
COPY IJ_Prefs.txt /opt/Fiji/IJ_Prefs.txt

RUN chmod 755 /opt/aligner/*.sh
RUN chmod 755 /opt/aligner-scripts/*.sh

RUN echo "Installing Fiji plugins for the aligner"
RUN cp -R /opt/aligner/fiji_plugins/* /opt/Fiji/plugins \
 && cp -R /opt/aligner/fiji_jars/* /opt/Fiji/jars

# ENV JAVACPP_PLATFORM_VERSION=1.5.10
# ENV FFMPEG_PLATFORM_VERSION=6.1.1-1.5.10

# RUN wget -O /opt/Fiji/jars/javacpp-platform-${JAVACPP_PLATFORM_VERSION}.jar \
#     https://repo.maven.apache.org/maven2/org/bytedeco/javacpp-platform/${JAVACPP_PLATFORM_VERSION}/javacpp-platform-${JAVACPP_PLATFORM_VERSION}.jar
# RUN wget -O /opt/Fiji/jars/ffmpeg-platform-${FFMPEG_PLATFORM_VERSION}.jar \
#     https://repo.maven.apache.org/maven2/org/bytedeco/ffmpeg-platform/${FFMPEG_PLATFORM_VERSION}/ffmpeg-platform-${FFMPEG_PLATFORM_VERSION}.jar

# RUN /opt/Fiji/ImageJ-linux64 --headless -macro /opt/aligner/fiji_macros/h5jinstall.ijm \
#  && rm -rf /root/.javacpp \
#  && rm -rf /opt/Fiji/jars/imagej-updater*.jar

RUN rm -rf /opt/Fiji/jars/imagej-updater*.jar

RUN echo "Installing Fiji LUTs for color depth"
ENV LUTS_SOURCE=/opt/aligner/fiji_luts
ENV LUTS_TARGET=/opt/Fiji/luts
RUN cp -R $LUTS_SOURCE/* $LUTS_TARGET \
 && /bin/rm -rf $LUTS_SOURCE

RUN echo "Fixing permissions"
RUN chown -R root:root /opt/*
RUN chmod -R g+r /opt/*
