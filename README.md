# nRF Connect SDK: sdk-docker

This repository contains definitions of docker images that may come in handy during development of nRF Connect SDK (NCS) applications.

## Build instructions

Each subdirectory contains a different docker image definition and `build.sh` script which takes various arguments to customize the image. You may examine the output of `build.sh --help` command to learn available options. Below are instructions to build all the images:

```bash
# Build `nrfconnect-toolchain` image composed of all utilities needed to 
# build, flash and debug nRF Connect SDK applications.
./nrfconnect-toolchain/build.sh --org nordicsemi

# Build `nrfconnect-chip` image for Connected Home over IP applications.
# It is based on `nrfconnect-toolchain` image and may walk a user through 
# the process of collecting sources of NCS and CHIP projects.
./nrfconnect-chip/build.sh --org nordicsemi
```

## Using nrfconnect-toolchain image

Once the image has been built or pulled from the docker hub you may easily build any nRF Connect SDK sample in the container by running the following commands:
```bash
# In the command below please replace '~/src/ncs' with location of your local copy
# of the nRF Connect SDK repository, however keep the '/var/ncs/' part unchanged -
# it will allow the container to automatically configure 'west' build system.
docker run --rm -it --volume ~/src/ncs:/var/ncs nordicsemi/nrfconnect-toolchain

# Then, inside the container run:
cd /var/ncs/zephyr/samples/hello_world/
west build -b nrf52840dk_nrf52840
```

To flash the firmware onto your development kit you need to run the container with `--privileged --volume /dev/serial:/dev/serial --volume /dev/bus/usb:/dev/bus/usb` arguments so that it's allowed to access serial interface on the DK.

```bash
# Run the image
docker run --rm -it --privileged --volume /dev/serial:/dev/serial --volume /dev/bus/usb:/dev/bus/usb --volume ~/src/ncs:/var/ncs nordicsemi/nrfconnect-toolchain

# Then, inside the container run:
cd /var/ncs/zephyr/samples/hello_world/
west flash
west debug
```

## Using nrfconnect-chip image

`nrfconnect-chip` image aims to help develop CHIP applications based on nRF Connect SDK. In case you have already checked out NCS and CHIP sources you may expose the source directories to the container and go straight to an example you wish to build:

```bash
# In the command below please replace '~/src/ncs' with location of your local copy
# of the nRF Connect SDK repository and, likewise, '~/src/chip' with location of 
# the CHIP repository.
docker run --rm -it --privileged --volume /dev/serial:/dev/serial --volume /dev/bus/usb:/dev/bus/usb \
           --volume ~/src/ncs:/var/ncs --volume ~/src/chip:/var/chip nordicsemi/nrfconnect-chip

# Then, inside the container run:
cd /var/chip/examples/lock-app/nrfconnect
/var/chip/bootstrap
west build -b nrf52840dk_nrf52840
west flash
west debug
```

You may use the image even if haven't fetched NCS nor CHIP repositories yet in which case the container may do the necessary setup for you. Hence not even `git` or `west` are needed to be installed on the host. For example:
```bash
# Create empty directories for NCS and CHIP sources
mkdir ~/src/ncs
mkdir ~/src/chip

# Run the image. The welcome screen should inform you about missing sources
docker run --rm -it --privileged --volume /dev/serial:/dev/serial --volume /dev/bus/usb:/dev/bus/usb \
           --volume ~/src/ncs:/var/ncs --volume ~/src/chip:/var/chip nordicsemi/nrfconnect-chip

# OUTPUT:
#
# Welcome to development environment for nRF Connect SDK and CHIP applications
# 
# - /var/ncs is empty
# 
#   to enable build of nRF Connect SDK applications run "setup" command which will fetch 
#   required nRF Connect SDK sources
# 
# - /var/chip is empty
# 
#   to enable build of CHIP applications run "setup" command which will fetch required
#  Connected Home over IP sources

# Run the setup as advised
setup

# OUTPUT:
#
# /var/ncs repository is empty. Do you wish to check out nRF Connect SDK sources [v1.3.0]? [Y/N] y
# ...
# /var/chip repository is empty. Do you wish to check out Project CHIP sources [master]? [Y/N] y
# ...
```