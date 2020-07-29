ARG BASE
FROM ${BASE}

ARG NCS_REVISION="master"
ARG CHIP_REVISION="master"

ENV NCS_REVISION ${NCS_REVISION}
ENV CHIP_REVISION ${CHIP_REVISION}

RUN set -x \
    #
    # Install autotools and Standalone CHIP dependencies
    #
    && chmod 777 /tmp && apt-get update \
    && apt-get -y install autoconf \
    && apt-get -y install --no-install-recommends sudo make g++ libssl-dev libtool libdbus-1-dev libdbus-glib-1-dev screen nano \
    && apt-get -y clean && apt-get -y autoremove \
    && rm -rf /tmp/* /var/lib/apt/lists/* \
    && :

RUN set -x \
    #
    # Configuration
    # 1. Add "setup" function which calls "/opt/setup" script and updates environment by sourcing zephyr-env.sh
    #
    && echo >> ~/.profile \
    && echo 'setup() { /opt/setup "$@" && { source /var/ncs/zephyr/zephyr-env.sh 2>/dev/null || true; }; }' >> ~/.profile \
    && echo 'export -f setup' >> ~/.profile \
    && :

# Copy welcome screen and setup script
COPY welcome.sh /opt/welcome
COPY setup.sh /opt/setup

# Make sure ~/.profile is always loaded
ENTRYPOINT ["/bin/bash", "--login", "-c"]
CMD ["/opt/welcome"]
