# nRF Connect SDK: sdk-docker

This repository contains definitions of docker images that may come in handy during development of nRF Connect SDK (NCS) applications.

## Build instructions

Each subdirectory contains a different docker image definition and `build.sh` script which takes various arguments to customize the image. You may examine the output of `build.sh --help` command to learn available options. Below are instructions to build all the images:

```bash
# Build `nrfconnect-toolchain` image composed of utilities needed to 
# build, flash and debug nRF Connect SDK applications.
./nrfconnect-toolchain/build.sh --org nordicsemi

# Build `nrfconnect-chip` image for Connected Home over IP applications.
# It is based on `nrfconnect-toolchain` image, but adds a few CHIP dependencies
# and a helper script for collecting sources of NCS and CHIP projects.
./nrfconnect-chip/build.sh --org nordicsemi
```

## Using nrfconnect-toolchain image

Once the image has been built or pulled from the docker hub and you have downloaded the NCS repository you may easily build any NCS sample in the container by running the following commands:
```bash
# In the command below please replace '~/src/ncs' with location of your local copy
# of the nRF Connect SDK repository, however keep the '/var/ncs/' part unchanged -
# it will allow the container to automatically configure 'west' build system.
docker run --rm -it --volume ~/src/ncs:/var/ncs nordicsemi/nrfconnect-toolchain

# Then, inside the container run:
cd /var/ncs/zephyr/samples/hello_world/
west build -b nrf52840dk_nrf52840
```

To flash the firmware onto your development kit you need to run the container with `--privileged --volume /dev:/dev` arguments so that the container is given access to serial devices on your computer.

```bash
# Run the image
docker run --rm -it --privileged --volume /dev:/dev --volume ~/src/ncs:/var/ncs nordicsemi/nrfconnect-toolchain

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
docker run --rm -it --privileged --volume /dev:/dev \
    --volume ~/src/ncs:/var/ncs --volume ~/src/chip:/var/chip nordicsemi/nrfconnect-chip

# Then, inside the container run:
/var/chip/bootstrap
cd /var/chip/examples/lock-app/nrfconnect
west build -b nrf52840dk_nrf52840
west flash
west debug

# Note that 'screen' utility is included in the image, so you may also attach to 
# the UART interface on the DK to get access to application logs and Zephyr shell:
screen /dev/ttyACM0 115200

# In case you have several DKs connected, you may learn the mapping between their full
# names and '/dev/ttyACM*' device nodes by running the command:
ls -l /dev/serial/by-id
```

You may use the image even if you haven't fetched NCS nor CHIP repositories yet in which case the container may do the necessary setup for you. Hence not even `git` or `west` need to be installed on the host. For example:
```bash
# Create empty directories for NCS and CHIP sources
mkdir ~/src/ncs
mkdir ~/src/chip

# Run the image. The welcome screen should inform you about missing sources
docker run --rm -it --privileged --volume /dev:/dev \
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
# /var/ncs repository is empty. Do you wish to check out nRF Connect SDK sources [master]? [Y/N] y
# ...
# /var/chip repository is empty. Do you wish to check out Project CHIP sources [master]? [Y/N] y
# ...

# From now on you may run the commands presented in the previous paragraph:
/var/chip/bootstrap
cd /var/chip/examples/lock-app/nrfconnect
west build -b nrf52840dk_nrf52840
west flash
west debug
screen /dev/ttyACM0 115200
```