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

FROM ubuntu:20.10

ARG TOOLCHAIN_URL="https://developer.arm.com/-/media/Files/downloads/gnu-rm/9-2020q2/gcc-arm-none-eabi-9-2020-q2-update-x86_64-linux.tar.bz2"
ARG DTC_URL="http://ftp.br.debian.org/debian/pool/main/d/device-tree-compiler/device-tree-compiler_1.4.7-3_amd64.deb"
ARG NRF_TOOLS_URL="https://www.nordicsemi.com/-/media/Software-and-other-downloads/Desktop-software/nRF-command-line-tools/sw/Versions-10-x-x/10-12-1/nRFCommandLineTools10121Linuxamd64.tar.gz"
ARG NCS_REVISION="master"

RUN set -x \
    #
    # Install apt packages (gcc and libpython3-dev are temporarily needed to install some pip modules)
    #
    && apt-get update && apt-get -y upgrade \
    && apt-get -y install --no-install-recommends bzip2 curl ninja-build python3-pip git device-tree-compiler \
    && apt-get -y install --no-install-recommends gcc libpython3-dev \
    #
    # nRF Tools for flashing software on Nordic devices, and accessing device logs
    #
    && curl ${NRF_TOOLS_URL} | tar xz -C /tmp \
    && dpkg -i --force-depends /tmp/JLink_Linux_*.deb \
    && dpkg -i --force-depends /tmp/nRF-Command-Line-Tools_*.deb \
    && apt-get -y install --fix-broken \
    #
    # GCC ARM Embedded Toolchain
    #
    && curl -L ${TOOLCHAIN_URL} | tar xj -C /opt --exclude='*/share/doc' \
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
    && west update \
    && python3 -m pip install --no-cache-dir -r zephyr/scripts/requirements.txt \
    && python3 -m pip install --no-cache-dir -r nrf/scripts/requirements.txt \
    && python3 -m pip install --no-cache-dir -r bootloader/mcuboot/scripts/requirements.txt) \
    #
    # Cleanup
    #
    && apt-get -y remove gcc libpython3-dev \
    && apt-get -y clean && apt-get -y autoremove \
    && rm -rf /tmp/* /var/lib/apt/lists/* ~/.cache/* \
    && :

ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8
ENV ZEPHYR_TOOLCHAIN_VARIANT=gnuarmemb
ENV GNUARMEMB_TOOLCHAIN_PATH=/opt/gcc-arm-none-eabi-9-2020-q2-update
