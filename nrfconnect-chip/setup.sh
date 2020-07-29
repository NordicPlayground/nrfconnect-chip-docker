#!/bin/bash

# Assume 'yes' for all questions
declare -i YES_TO_ALL

usage() {
    cat >&2 <<EOF
Usage: setup [OPTION]...
Setup development environment for nRF Connect SDK and CHIP applications.

Options:
  -y            answer 'yes' to all questions
  --ncs <rev>   revision of nRF Connect SDK to check out if /var/ncs directory is empty
  --chip <rev>  revision of CHIP to check out if /var/chip directory is empty
EOF
    exit 1
}

setup_ncs() {
    [[ -d /var/ncs ]] || {
        echo "/var/ncs is not mounted, skipping..." >&2
        return 0
    }

    [[ -z "$(ls -A /var/ncs)" ]] || {
        echo "/var/ncs is not empty, skipping..." >&2
        return 0
    }

    if ! ((YES_TO_ALL)); then
        local yn
        read -p "/var/ncs repository is empty. Do you wish to check out nRF Connect SDK sources [$NCS_REVISION]? [Y/N] " yn
        [[ $yn =~ [Yy].* ]] || return 0
    fi

    (cd /var/ncs \
        && west init -m https://github.com/nrfconnect/sdk-nrf --mr "$NCS_REVISION" \
        && west update)
}

setup_chip() {
     [[ -d /var/chip ]] || {
        echo "/var/chip is not mounted, skipping..." >&2
        return 0
    }

    [[ -z "$(ls -A /var/chip)" ]] || {
        echo "/var/chip is not empty, skipping..." >&2
        return 0
    }

    if ! ((YES_TO_ALL)); then
        local yn
        read -p "/var/chip repository is empty. Do you wish to check out Project CHIP sources [$CHIP_REVISION]? [Y/N] " yn
        [[ $yn =~ [Yy].* ]] || return 0
    fi

    (cd /var/chip \
        && git clone --single-branch --branch "$CHIP_REVISION" https://github.com/project-chip/connectedhomeip.git . \
        && git submodule update --init)
}

while (($#)); do
    case "$1" in
        -y) YES_TO_ALL=1;;
        --ncs) NCS_REVISION="$2"; shift;;
        --chip) CHIP_REVISION="$2"; shift;;
        --help) usage;;
    esac
    shift
done

setup_ncs
setup_chip