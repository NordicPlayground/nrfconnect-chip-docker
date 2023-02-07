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

FROM ubuntu:20.04

ARG TOOLCHAIN_SHA256="ae31dc109e4b24b8642efd3eb499bf6b027741493153079449ae5ab87b58fdeb"
ARG TOOLCHAIN_URL="https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v0.15.2/zephyr-sdk-0.15.2_linux-x86_64_minimal.tar.gz"
ARG NRF_TOOLS_SHA256="ad74e977520d5d05c028b7cb98dd382c35ba15df432c8e2bde9ccf8704380447"
ARG NRF_TOOLS_URL="https://nsscprodmedia.blob.core.windows.net/prod/software-and-other-downloads/desktop-software/nrf-command-line-tools/sw/versions-10-x-x/10-19-0/nrf-command-line-tools_10.19.0_amd64.deb"
ARG JLINK_SHA256="a2880364386d0c9663beca4da16ef61fa1db93d405e024f5d535061dfe53d0e8"
ARG JLINK_URL="https://www.segger.com/downloads/jlink/JLink_Linux_V780c_x86_64.deb"
ARG NCS_REVISION="v2.2.0"

RUN set -x \
    #
    # Install apt packages (gcc and libpython3-dev are temporarily needed to install some pip modules)
    #
    && DEBIAN_FRONTEND=noninteractive apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get -yq install --no-install-recommends unzip curl wget ninja-build python3-pip git device-tree-compiler libusb-1.0-0 libncurses5 \
    && DEBIAN_FRONTEND=noninteractive apt-get -yq install --no-install-recommends gcc libpython3-dev libsm6 \
    #
    # nRF Tools for flashing software on Nordic devices, and accessing device logs
    #
    && (mkdir /tmp/tools && cd /tmp/tools \
    && curl -L -X POST -d'accept_license_agreement=accepted' -o jlink.deb ${JLINK_URL} \
    && echo "${JLINK_SHA256} jlink.deb" | sha256sum -c - \
    && curl -L -o tools.deb ${NRF_TOOLS_URL} \
    && echo "${NRF_TOOLS_SHA256} tools.deb" | sha256sum -c - \
    && DEBIAN_FRONTEND=noninteractive apt-get -yq install --no-install-recommends ./jlink.deb ./tools.deb) \
    #
    # nRF Connect SDK dependencies
    #
    && python3 -m pip install --no-cache-dir -U pip setuptools wheel \
    && python3 -m pip install --no-cache-dir cmake west pc_ble_driver_py \
    #
    # GCC ARM Embedded Toolchain
    #
    && (mkdir /tmp/toolchain && cd /tmp/toolchain \
    && curl -L -o toolchain.tar.gz ${TOOLCHAIN_URL} \
    && echo "${TOOLCHAIN_SHA256} toolchain.tar.gz" | sha256sum -c - \
    && tar xzf toolchain.tar.gz -C /opt \
    && /opt/zephyr-sdk-0.15.2/setup.sh -t arm-zephyr-eabi) \
    #
    # nRF Connect SDK in-source requirements
    #
    && (mkdir /tmp/ncs && cd /tmp/ncs \
    && west init -m https://github.com/nrfconnect/sdk-nrf --mr ${NCS_REVISION} \
    && west update --narrow -o=--depth=1 \
    && python3 -m pip install --no-cache-dir -r zephyr/scripts/requirements.txt \
    && python3 -m pip install --no-cache-dir -r nrf/scripts/requirements.txt \
    && python3 -m pip install --no-cache-dir -r bootloader/mcuboot/scripts/requirements.txt) \
    #
    # Cleanup
    #
    && DEBIAN_FRONTEND=noninteractive apt-get -yq remove gcc libpython3-dev \
    && DEBIAN_FRONTEND=noninteractive apt-get -yq clean \
    && DEBIAN_FRONTEND=noninteractive apt-get -yq autoremove \
    && rm -rf /tmp/* /var/lib/apt/lists/* ~/.cache/* \
    && :

ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8
ENV ZEPHYR_SDK_INSTALL_DIR=/opt/zephyr-sdk-0.15.2
ENV ZEPHYR_TOOLCHAIN_VARIANT=zephyr
