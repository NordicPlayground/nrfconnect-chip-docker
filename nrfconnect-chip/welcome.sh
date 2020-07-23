#!/bin/bash

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

  to enable build of nRF Connect SDK applications run the container with parameter 
  "--volume <ncs_dir>:/var/ncs", where <ncs_dir> is an absolute path to nRF Connect SDK 
  source directory (can be empty if you don't have it checked out already)

EOF
elif dir_empty /var/ncs; then
    cat >&2 <<EOF
- /var/ncs is empty

  to enable build of nRF Connect SDK applications run "setup" command which will fetch 
  required nRF Connect SDK sources

EOF
fi

if ! dir_exists /var/chip; then
    cat >&2 <<EOF
- /var/chip is not mounted

  to enable build of CHIP applications run the container with parameter 
  "--volume <chip_dir>:/var/chip", where <chip_dir> is an absolute path to CHIP source 
  directory (can be empty if you don't have it checked out already)

EOF
elif dir_empty /var/chip; then
    cat >&2 <<EOF
- /var/chip is empty

  to enable build of CHIP applications run "setup" command which will fetch required
  Connected Home over IP sources

EOF
fi

bash