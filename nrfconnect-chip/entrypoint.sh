#!/bin/bash

# Enable IPv6 forwarding
sysctl -w net.ipv6.conf.all.disable_ipv6=0 net.ipv6.conf.all.forwarding=1 >/dev/null 2>&1

# If RUNAS environmental variable is non-empty add a new user "build" with the user id equal to $RUNAS
# and switch to that user.
if [[ -n "$RUNAS" ]]; then
    useradd -s /bin/bash -u "$RUNAS" -m build \
        && echo build ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/build \
        && chmod 0440 /etc/sudoers.d/build \
        || exit 1
    su --session-command "$*" build
else
    bash -c "$*"
fi
