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

confirm() {
    if ! ((YES_TO_ALL)); then
        local yn
        read -p "$1 [Y/N] " yn
        [[ $yn =~ [Yy].* ]]
    fi
}

setup_ncs() {
    [[ -d /var/ncs ]] || {
        echo "/var/ncs is not mounted, skipping..." >&2
        return 0
    }

    # /var/ncs is empty
    if [[ -z "$(ls -A /var/ncs)" ]]; then 
        confirm "/var/ncs repository is empty. Do you wish to check out nRF Connect SDK sources [$NCS_REVISION]?" || return 0
        (cd /var/ncs \
            && west init -m https://github.com/nrfconnect/sdk-nrf --mr "$NCS_REVISION" \
            && west update)
    # Current HEAD is a branch tracking an upstream
    elif git -C /var/ncs/nrf rev-parse --abbrev-ref HEAD@{u} 2>/dev/null >&2; then
        confirm "/var/ncs repository may be updated. Do you wish to continue?" || return 0
        (cd /var/ncs/nrf \
            && git pull --ff-only \
            && west update)
    # Current HEAD is either not a branch or it's not tracking any upstream branch
    elif git -C /var/ncs/nrf status 2>/dev/null >&2; then
        echo "/var/ncs repository is initialized, skipping..." >&2
    # Something is wrong with the repo...
    else
        echo "/var/ncs does not seem to be valid nRF Connect SDK repository! Did you provide a correct path?" >&2
        return 1
    fi
}

setup_chip() {
     [[ -d /var/chip ]] || {
        echo "/var/chip is not mounted, skipping..." >&2
        return 0
    }

    # /var/chip is empty
    if [[ -z "$(ls -A /var/chip)" ]]; then
        confirm "/var/chip repository is empty. Do you wish to check out Project CHIP sources [$CHIP_REVISION]?" || return 0

        local -a CLONE_ARGS
        [[ "$CHIP_REVISION" == master ]] && CLONE_ARGS=(--single-branch --branch "$CHIP_REVISION")

        (cd /var/chip \
            && git clone -n "${CLONE_ARGS[@]}" https://github.com/project-chip/connectedhomeip.git . \
            && git checkout "$CHIP_REVISION" \
            && git submodule update --init)
    # Current HEAD is a branch tracking an upstream
    elif git -C /var/chip rev-parse --abbrev-ref HEAD@{u} 2>/dev/null >&2; then
        confirm "/var/chip repository may be updated. Do you wish to continue?" || return 0
        (cd /var/chip \
            && git pull --ff-only \
            && git submodule update --init)
    # Current HEAD is either not a branch or it's not tracking any upstream branch
    elif git -C /var/ncs/nrf status 2>/dev/null >&2; then
        echo "/var/chip repository is initialized, skipping..." >&2
    # Something is wrong with the repo...
    else
        echo "/var/chip does not seem to be valid CHIP repository! Did you provide a correct path?" >&2
        return 1
    fi
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

setup_ncs && setup_chip