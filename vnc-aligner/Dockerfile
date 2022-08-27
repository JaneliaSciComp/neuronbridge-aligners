FROM oraclelinux:8

RUN yum install -y epel-release && \
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
RUN yum install -y fuse-devel s3fs-fuse groff-base wget tar unzip less

WORKDIR /awsinstall
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
RUN unzip awscliv2.zip
RUN ./aws/install
RUN rm -rf aws*

WORKDIR /opt

# Prereqs for Fiji
RUN yum install -y \
        mesa-libGLU \
        qt5-qtbase qt5-qtx11extras \
        libXv numactl-libs libXtst-devel libXrender

RUN echo "Installing Fiji"
# Install Fiji
ENV FIJI_FILE=fiji-linux64.tar.gz
RUN wget -q --no-check-certificate https://downloads.imagej.net/fiji/latest/${FIJI_FILE}
RUN tar xvf $FIJI_FILE && /bin/rm -rf ${FIJI_FILE} && \
    rm -rf Fiji && \
    mv Fiji.app Fiji

RUN echo "Installing CMTK"
# Prereqs for CMTK
RUN yum install -y fftw-libs-double
# Install CMTK
ENV CMTK_FILE=cmtk-20171001-sl7avx.tgz
RUN wget -q http://workstation.int.janelia.org/files/tools/${CMTK_FILE}
RUN tar xvf $CMTK_FILE && /bin/rm -f $CMTK_FILE && \
    ln -s cmtk-scm-2017-10-01 CMTK

ENV S3_TEMPLATES_MOUNTPOINT=/s3_alignment_templates

RUN mkdir -p ${S3_TEMPLATES_MOUNTPOINT}

# copy alignment scripts
COPY aligner /opt/aligner
COPY scripts /opt/aligner-scripts

RUN chmod 755 /opt/aligner/*.sh
RUN chmod 755 /opt/aligner-scripts/*.sh

RUN echo "Installing Fiji plugins for the aligner"
ENV PLUGINS_SOURCE=/opt/aligner/fiji_plugins
ENV PLUGINS_TARGET=/opt/Fiji/plugins
RUN cp -R $PLUGINS_SOURCE/* $PLUGINS_TARGET && /bin/rm -rf $PLUGINS_SOURCE

RUN echo "Installing Fiji LUTs for color depth"
ENV LUTS_SOURCE=/opt/aligner/fiji_luts
ENV LUTS_TARGET=/opt/Fiji/luts
RUN cp -R $LUTS_SOURCE/* $LUTS_TARGET && /bin/rm -rf $LUTS_SOURCE

RUN echo "Fixing permissions"
RUN chown -R root:root /opt/*
RUN chmod -R g+r /opt/*
