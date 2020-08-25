ARG BASE
FROM ${BASE}

ARG NCS_REVISION="master"
ARG CHIP_REVISION="master"

ENV NCS_REVISION ${NCS_REVISION}
ENV CHIP_REVISION ${CHIP_REVISION}

ENV WPANTUND_REVISION a4fb3ca5c53701f1267321674093d2fdeeb7dbe5

RUN set -x \
    #
    # Install autotools and Standalone CHIP dependencies
    #
    && chmod 777 /tmp && apt-get update \
    && apt-get -y install autoconf \
    && apt-get -y install --no-install-recommends sudo make g++ libssl-dev libtool dbus libdbus-1-dev \
        libdbus-glib-1-dev libboost-dev autoconf-archive libreadline-dev g++-multilib \
        iputils-ping net-tools nano screen \
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


RUN set -x \
    #
    # Configuration
    # 1. Add "setup" function which calls "/opt/setup" script and updates environment by sourcing zephyr-env.sh
    #
    && echo >> ~/.profile \
    && echo 'setup() { /opt/setup "$@" && { source /var/ncs/zephyr/zephyr-env.sh 2>/dev/null || true; }; }' >> ~/.profile \
    && echo 'export -f setup' >> ~/.profile \
    # 2. Kernel configuration
    && echo '/sbin/sysctl -w net.ipv6.conf.all.disable_ipv6=0 net.ipv6.conf.all.forwarding=1 > /dev/null' >> ~/.profile \
    && :

# Copy the scripts and the NCP firmware
COPY welcome.sh /opt/welcome
COPY setup.sh /opt/setup
COPY ncp_4.0.0_pca10056.hex /opt/ncp_4.0.0_pca10056.hex

# Make sure ~/.profile is always loaded
ENTRYPOINT ["/bin/bash", "--login", "-c"]
CMD ["/opt/welcome"]
