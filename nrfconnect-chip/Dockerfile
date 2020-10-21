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
    && apt-get -y install --no-install-recommends sudo make g++ g++-multilib python \
        libssl-dev libtool dbus libdbus-1-dev libdbus-glib-1-dev libboost-dev autoconf-archive libreadline-dev  \
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

RUN set -x \
    #
    # Add the default container user
    #
    && groupadd -g ${USER_GID} ${GROUPNAME} \
    && useradd -s /bin/bash -u ${USER_UID} -g ${USER_GID} -m ${USERNAME} \
    && echo ${USERNAME} ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/${USERNAME} \
    && chmod 0440 /etc/sudoers.d/${USERNAME} \
    && :

USER ${USERNAME}:${GROUPNAME}

RUN set -x \
    #
    # Configure user profile:
    # 1. Add "setup" function which calls "/opt/setup" script and updates environment by sourcing zephyr-env.sh
    # 2. Kernel configuration
    #
    && echo >> ~/.profile \
    && echo "umask 002" >> ~/.profile \
    && echo 'setup() { /opt/setup "$@" && { source /var/ncs/zephyr/zephyr-env.sh 2>/dev/null || true; }; }' >> ~/.profile \
    && echo 'export -f setup' >> ~/.profile \
    && echo '/sbin/sysctl -w net.ipv6.conf.all.disable_ipv6=0 net.ipv6.conf.all.forwarding=1 >/dev/null 2>&1' >> ~/.profile \
    && :

# Copy the scripts and the NCP firmware
COPY welcome.sh /opt/welcome
COPY setup.sh /opt/setup
COPY ncp_4.0.0_pca10056.hex /opt/ncp_4.0.0_pca10056.hex

# Make sure ~/.profile is always loaded
ENTRYPOINT ["/bin/bash", "--login", "-c"]
CMD ["/opt/welcome"]
