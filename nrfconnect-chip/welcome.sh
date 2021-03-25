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

dir_exists() { 
    [[ -d "$1" ]] 
}

dir_empty() { 
    [[ $(ls -A "$1" | wc -l) -eq 0 ]] 
}

echo "Welcome to development environment for nRF Connect SDK and CHIP applications" >&2
echo >&2

if ! dir_exists /var/ncs; then
    cat >&2 <<EOF
- /var/ncs is not mounted   

  To enable build of nRF Connect SDK applications run the container with parameter:

    --volume <ncs_dir>:/var/ncs

  where <ncs_dir> is an absolute path to nRF Connect SDK source directory (can be
  empty if you don't have the SDK installed yet).

EOF
elif dir_empty /var/ncs; then
    cat >&2 <<EOF
- /var/ncs is empty

  To enable build of nRF Connect SDK applications run "setup" command which will fetch 
  required nRF Connect SDK sources.

EOF
fi

if ! dir_exists /var/chip; then
    cat >&2 <<EOF
- /var/chip is not mounted

  To enable build of CHIP applications run the container with parameter:

    --volume <chip_dir>:/var/chip

  where <chip_dir> is an absolute path to CHIP source directory (can be empty if you
  don't have CHIP installed yet).

EOF
elif dir_empty /var/chip; then
    cat >&2 <<EOF
- /var/chip is empty

  To enable build of CHIP applications run "setup" command which will fetch required
  Connected Home over IP sources.

EOF
fi

bash