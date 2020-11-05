#!/bin/bash

dir_exists() { 
    [[ -d "$1" ]] 
}

dir_empty() { 
    [[ $(ls -A "$1" | wc -l) -eq 0 ]] 
}

recommended_ncs_revision() {
    curl -o- https://raw.githubusercontent.com/project-chip/connectedhomeip/master/integrations/docker/images/chip-build-nrf-platform/Dockerfile 2>/dev/null \
        | awk -F= '/ARG NCS_REVISION/{ print $2 }' \
        | awk '{ print $1 }'
}

ncs_commit_id() {
    git -C /var/ncs/nrf rev-list -n1 "$1" 2>/dev/null
}

RECOMMENDED_NCS_REVISION=$(recommended_ncs_revision)
[[ -n "$RECOMMENDED_NCS_REVISION" ]] && NCS_REVISION="$RECOMMENDED_NCS_REVISION"

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
elif [[ -n "$RECOMMENDED_NCS_REVISION" && "$(ncs_commit_id HEAD)" != "$(ncs_commit_id "$RECOMMENDED_NCS_REVISION")" ]]; then
    cat >&2 <<EOF
- /var/ncs may be outdated

  Current version of nRF Connect SDK may not be appropriate for building CHIP
  applications. Please run:

    setup --ncs ${RECOMMENDED_NCS_REVISION}

  to switch to the recommended version.

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