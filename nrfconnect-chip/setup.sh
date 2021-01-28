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

# Assume 'yes' for all questions
declare -i YES_TO_ALL

# --ncs <rev> argument was provided 
declare -i NCS_ARG_PRESENT

# --chip <rev> argument was provided
declare -i CHIP_ARG_PRESENT

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

current_branch() {
    git -C "$1" rev-parse --abbrev-ref HEAD 2>/dev/null
}

is_current_branch_tracking() {
    git -C "$1" rev-parse --abbrev-ref "HEAD@{u}" 2>/dev/null >&2
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
    # Switch HEAD to a different revision
    elif ((NCS_ARG_PRESENT)) && [[ "$(current_branch /var/ncs/nrf)" != "$NCS_REVISION" ]]; then
        confirm "/var/ncs repository is initialized. Do you wish to check out revision [$NCS_REVISION]?" || return 0
        (cd /var/ncs/nrf \
            && git fetch \
            && git checkout "$NCS_REVISION" \
            && (! is_current_branch_tracking . || git pull --ff-only) \
            && west update)
    # Current HEAD is a branch tracking an upstream
    elif is_current_branch_tracking /var/ncs/nrf; then
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
        (cd /var/chip \
            && git clone -n https://github.com/project-chip/connectedhomeip.git . \
            && git checkout "$CHIP_REVISION" \
            && git submodule update --init)
    # Switch HEAD to a different revision
    elif ((CHIP_ARG_PRESENT)) && [[ "$(current_branch /var/chip)" != "$CHIP_REVISION" ]]; then
        confirm "/var/chip repository is initialized. Do you wish to check out revision [$CHIP_REVISION]?" || return 0
        (cd /var/chip \
            && git fetch \
            && git checkout "$CHIP_REVISION" \
            && (! is_current_branch_tracking . || git pull --ff-only) \
            && git submodule update --init)
    # Current HEAD is a branch tracking an upstream
    elif is_current_branch_tracking /var/chip; then
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
        --ncs) NCS_REVISION="$2"; NCS_ARG_PRESENT=1; shift;;
        --chip) CHIP_REVISION="$2"; CHIP_ARG_PRESENT=1; shift;;
        --help) usage;;
    esac
    shift
done

setup_ncs && setup_chip