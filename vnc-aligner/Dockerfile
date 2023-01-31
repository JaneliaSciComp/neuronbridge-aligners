FROM scientificlinux/sl:7

RUN yum update -y && \
    yum install -y epel-release && \
    yum install -y \
        net-tools \
        libX11-devel \
        Xvfb \
        ImageMagick \
        tree jq bc

RUN yum install -y python3-pip && \
    pip3 install --upgrade pip && \
    pip3 install yq

RUN echo "Installing S3 FUSE and AWS CLI"
RUN yum install -y fuse-devel s3fs-fuse \
        groff wget tar unzip less

WORKDIR /awsinstall
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
RUN unzip awscliv2.zip
RUN ./aws/install
RUN rm -rf aws*

WORKDIR /opt

# Prereqs for Fiji and CMTK
RUN yum localinstall --nogpgcheck -y https://download1.rpmfusion.org/free/el/rpmfusion-free-release-7.noarch.rpm && \
    yum install -y \
        ffmpeg \
        mesa-libGLU libXtst-devel libXrender \
        fftw-libs-double

RUN echo "Installing Fiji"
ARG FIJI_VERSION=20221005-1117
# Install Fiji
ENV FIJI_FILE=fiji-linux64.zip
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

RUN wget https://github.com/JaneliaSciComp/tools-archive/releases/download/1.0.0/${CMTK_FILE} && \
    tar xvf ${CMTK_FILE} && \
    /bin/rm -f ${CMTK_FILE} && \
    ln -s ${CMTK_NAME} CMTK

ENV CMTK_HOME=/opt/CMTK

# create mount points for MIP templates and VNC alignment templates
ENV S3_MIP_TEMPLATES_MOUNTPOINT=/s3_mip_templates
ENV S3_VNC_TEMPLATES_MOUNTPOINT=/s3_vnc_alignment_templates

RUN mkdir -p ${S3_MIP_TEMPLATES_MOUNTPOINT}
RUN mkdir -p ${S3_VNC_TEMPLATES_MOUNTPOINT}

# copy alignment scripts
COPY aligner /opt/aligner
COPY scripts /opt/aligner-scripts

RUN chmod 755 /opt/aligner/*.sh
RUN chmod 755 /opt/aligner-scripts/*.sh

RUN echo "Installing Fiji plugins for the aligner"
ENV PLUGINS_SOURCE=/opt/aligner/fiji_plugins
ENV PLUGINS_TARGET=/opt/Fiji/plugins
RUN cp -R $PLUGINS_SOURCE/* $PLUGINS_TARGET \
 && /bin/rm -rf $PLUGINS_SOURCE \
 && /opt/Fiji/ImageJ-linux64 --run /opt/aligner/fiji_plugins/H5J_Installer.jar

RUN echo "Installing Fiji LUTs for color depth"
ENV LUTS_SOURCE=/opt/aligner/fiji_luts
ENV LUTS_TARGET=/opt/Fiji/luts
RUN cp -R $LUTS_SOURCE/* $LUTS_TARGET && /bin/rm -rf $LUTS_SOURCE

RUN echo "Fixing permissions"
RUN chown -R root:root /opt/*
RUN chmod -R g+r /opt/*
