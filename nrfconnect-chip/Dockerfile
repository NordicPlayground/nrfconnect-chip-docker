ARG BASE
FROM ${BASE}

ARG NCS_REVISION="master"
ARG CHIP_REVISION="master"
ARG WPANTUND_REVISION="a4fb3ca5c53701f1267321674093d2fdeeb7dbe5"
ARG GN_BUILD_URL="https://chrome-infra-packages.appspot.com/dl/gn/gn/linux-amd64/+/latest"

ARG USERNAME="build"
ARG GROUPNAME=${USERNAME}
ARG USER_UID="1000"
ARG USER_GID=${USER_UID}

ENV NCS_REVISION ${NCS_REVISION}
ENV CHIP_REVISION ${CHIP_REVISION}
ENV ZEPHYR_BASE /var/ncs/zephyr

RUN set -x \
    #
    # Install autotools, CHIP dependencies and utilities
    #
    && chmod 777 /tmp && apt-get update \
    && apt-get -y install autoconf \
    && apt-get -y install --no-install-recommends sudo make g++ g++-multilib python dbus \
        libssl-dev libtool libdbus-1-dev libdbus-glib-1-dev libboost-dev autoconf-archive \
        libreadline-dev libavahi-client-dev libpython3-dev python3-venv \
        iputils-ping net-tools nano screen \
    #
    # Install GN build
    #
    && curl -L -o /tmp/gn.zip ${GN_BUILD_URL} \
    && python3 -c "from zipfile import *; ZipFile('/tmp/gn.zip').extract('gn', '/usr/bin')" \
    && chmod +x /usr/bin/gn \
    #
    # Cleanup
    #
    && apt-get -y clean && apt-get -y autoremove \
    && rm -rf /tmp/* /var/lib/apt/lists/* \
    && :

RUN set -x \
    #
    # Build and install wpantund
    #
    && git clone -n https://github.com/openthread/wpantund \
    && cd wpantund \
    && git checkout ${WPANTUND_REVISION} \
    && ./bootstrap.sh \
    && ./configure --sysconfdir=/etc \
    && make \
    && make install \
    && cd .. \
    && rm -rf ./wpantund \
    && :

# Copy the scripts and the NCP firmware
COPY entrypoint.sh /opt/entrypoint
COPY welcome.sh /opt/welcome
COPY setup.sh /usr/bin/setup
COPY ncp_4.0.0_pca10056.hex /opt/ncp_4.0.0_pca10056.hex

ENTRYPOINT ["/opt/entrypoint"]
CMD ["/opt/welcome"]
