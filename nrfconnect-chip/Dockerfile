ARG BASE
FROM ${BASE}

ARG NCS_REVISION="v1.3.0"
ARG CHIP_REVISION="master"

ENV NCS_REVISION ${NCS_REVISION}
ENV CHIP_REVISION ${CHIP_REVISION}

RUN set -x \
    #
    # Install autotools and Standalone CHIP dependencies
    #
    && chmod 777 /tmp && apt-get update \
    && apt-get -y install autoconf \
    && apt-get -y install --no-install-recommends sudo g++ libssl-dev libtool libdbus-1-dev libdbus-glib-1-dev \
    && apt-get -y clean && apt-get -y autoremove \
    && rm -rf /tmp/* /var/lib/apt/lists/* \
    && :

COPY setup.sh /usr/local/bin/setup
COPY welcome.sh /usr/local/bin/welcome
CMD welcome