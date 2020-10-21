FROM ubuntu:20.04

ARG TOOLCHAIN_URL="https://developer.arm.com/-/media/Files/downloads/gnu-rm/9-2020q2/gcc-arm-none-eabi-9-2020-q2-update-x86_64-linux.tar.bz2"
ARG DTC_URL="http://mirrors.edge.kernel.org/ubuntu/pool/main/d/device-tree-compiler/device-tree-compiler_1.4.7-3ubuntu2_amd64.deb"
ARG NRF_TOOLS_URL="https://www.nordicsemi.com/-/media/Software-and-other-downloads/Desktop-software/nRF-command-line-tools/sw/Versions-10-x-x/10-7-0/nRFCommandLineTools1070Linuxamd64tar.gz"
ARG NCS_REVISION="master"

RUN set -x \
    #
    # Install apt packages (gcc and libpython3-dev are temporarily needed to install some pip modules)
    #
    && apt-get update && apt-get -y upgrade \
    && apt-get -y install --no-install-recommends curl ninja-build python3-pip git \
    && apt-get -y install --no-install-recommends gcc libpython3-dev \
    #
    # Device Tree Compiler
    #
    && curl -o /tmp/dtc.deb ${DTC_URL} && dpkg -i /tmp/dtc.deb \
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