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

FROM ubuntu:21.04

ARG TOOLCHAIN_MD5="fe0029de4f4ec43cf7008944e34ff8cc"
ARG TOOLCHAIN_URL="https://developer.arm.com/-/media/Files/downloads/gnu-rm/9-2019q4/gcc-arm-none-eabi-9-2019-q4-major-x86_64-linux.tar.bz2"
ARG NRF_TOOLS_SHA256="05982D0E104A8723D2EA1BFD5AA12493C87164DE2D3A1D62C8B2D21BD40CCB88"
ARG NRF_TOOLS_URL="https://www.nordicsemi.com/-/media/Software-and-other-downloads/Desktop-software/nRF-command-line-tools/sw/Versions-10-x-x/10-15-1/nrf-command-line-tools-10.15.1_Linux-amd64.zip"
ARG NCS_REVISION="main"

RUN set -x \
    #
    # Install apt packages (gcc and libpython3-dev are temporarily needed to install some pip modules)
    #
    && DEBIAN_FRONTEND=noninteractive apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get -yq install --no-install-recommends bzip2 unzip curl ninja-build python3-pip git device-tree-compiler libusb-1.0-0 \
    && DEBIAN_FRONTEND=noninteractive apt-get -yq install --no-install-recommends gcc libpython3-dev libsm6 \
    #
    # nRF Tools for flashing software on Nordic devices, and accessing device logs
    #
    && (mkdir /tmp/tools && cd /tmp/tools \
    && echo "${NRF_TOOLS_SHA256} tools.zip" >> tools.zip.sha256 \
    && curl -L -o tools.zip ${NRF_TOOLS_URL} \
    && sha256sum -c tools.zip.sha256 \
    && unzip tools.zip \
    && dpkg -i nrf-command-line-tools_*_amd64.deb \
    && dpkg -i JLink_Linux_*x86_64.deb) \
    #
    # GCC ARM Embedded Toolchain
    #
    && (mkdir /tmp/toolchain && cd /tmp/toolchain \
    && echo "${TOOLCHAIN_MD5} toolchain.tar.bz2" > toolchain.tar.bz2.md5 \
    && curl -L -o toolchain.tar.bz2 ${TOOLCHAIN_URL} \
    && md5sum -c toolchain.tar.bz2.md5 \
    && tar xjf toolchain.tar.bz2 -C /opt --exclude='*/share/doc') \
    #
    # nRF Connect SDK dependencies
    #
    && python3 -m pip install --no-cache-dir -U pip setuptools wheel \
    && python3 -m pip install --no-cache-dir cmake west pc_ble_driver_py \
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
ENV ZEPHYR_TOOLCHAIN_VARIANT=gnuarmemb
ENV GNUARMEMB_TOOLCHAIN_PATH=/opt/gcc-arm-none-eabi-9-2019-q4-major/
