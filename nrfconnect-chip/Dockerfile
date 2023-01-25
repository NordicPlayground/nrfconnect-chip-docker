#!/bin/bash
#
# Copyright (c) 2021, Nordic Semiconductor
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without modification,
# are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice, this
#    list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice, this
#    list of conditions and the following disclaimer in the documentation and/or
#    other materials provided with the distribution.
#
# 3. Neither the name of the copyright holder nor the names of its contributors may
#    be used to endorse or promote products derived from this software without
#    specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
# IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
# INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
# NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
# PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

ARG BASE
FROM ${BASE}

ARG NCS_REVISION="main"
ARG CHIP_REVISION="master"
ARG GN_BUILD_URL="https://chrome-infra-packages.appspot.com/dl/gn/gn/linux-amd64/+/latest"

ARG USERNAME="build"
ARG GROUPNAME=${USERNAME}
ARG USER_UID="1000"
ARG USER_GID=${USER_UID}

ENV NCS_REVISION ${NCS_REVISION}
ENV CHIP_REVISION ${CHIP_REVISION}
ENV ZEPHYR_BASE /var/ncs/zephyr

ENV ZAP_VERSION v2023.01.19-nightly
ENV ZAP_INSTALL_PATH /var/zap/${ZAP_VERSION}

RUN set -x \
    #
    # Install autotools, CHIP dependencies and utilities
    #
    && chmod 777 /tmp && apt-get update \
    && apt-get -y install autoconf \
    && apt-get -y install --no-install-recommends sudo make g++ g++-multilib \
        libssl-dev libtool libdbus-1-dev libdbus-glib-1-dev libavahi-client-dev \
        libpython3-dev libgirepository-1.0-1 python3-venv nano screen python-is-python3\
    #
    # Install GN build
    #
    && curl -L -o /tmp/gn.zip ${GN_BUILD_URL} \
    && python3 -c "from zipfile import *; ZipFile('/tmp/gn.zip').extract('gn', '/usr/bin')" \
    && chmod +x /usr/bin/gn \
    #
    # Install nrfutil
    #
    && python3 -m pip install --no-cache-dir nrfutil \
    #
    # Install Chip python dependecies
    #
    && python3 -m pip install --no-cache-dir lark \
    && python3 -m pip install --no-cache-dir stringcase \
    #
    # Install Zap cli
    #
    && sudo mkdir -p $ZAP_INSTALL_PATH \
    && curl -L https://github.com/project-chip/zap/releases/download/$ZAP_VERSION/zap-linux.zip --output $ZAP_INSTALL_PATH/zap-linux.zip \
    && unzip $ZAP_INSTALL_PATH/zap-linux.zip zap-cli -d $ZAP_INSTALL_PATH \
    && rm $ZAP_INSTALL_PATH/zap-linux.zip \
    #
    # Cleanup
    #
    && apt-get -y clean && apt-get -y autoremove \
    && rm -rf /tmp/* /var/lib/apt/lists/* \
    && :

# Copy the scripts
COPY entrypoint.sh /opt/entrypoint
COPY welcome.sh /opt/welcome
COPY setup.sh /usr/bin/setup

ENTRYPOINT ["/opt/entrypoint"]
CMD ["/opt/welcome"]
