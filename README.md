# nRF Connect SDK: nrfconnect-chip-docker

This repository contains definition of `nrfconnect-chip` docker image which may come in handy during development of CHIP applications based on nRF Connect SDK (NCS).

> **Important**
> 
> This Docker image is no longer maintained, so you will not be able to use it without modifications to build Matter applications based on recent versions of nRF Connect SDK, such as 2.3.0 or newer. It is now recommended to use [Toolchain Manager](https://developer.nordicsemi.com/nRF_Connect_SDK/doc/latest/nrf/getting_started/assistant.html#install-toolchain-manager) to install nRF Connect SDK with all dependencies natively on your operating system. Note that Toolchain Manager is now available for Linux as well.

## Build instructions

Below are steps needed to build `nrfconnect-chip` docker image. Note that the `build.sh` scripts take various optional arguments to customize the build and `build.sh --help` is the way to list all available options.

```bash
# Build `nrfconnect-toolchain` image composed of utilities needed to 
# build, flash and debug nRF Connect SDK applications.
./nrfconnect-toolchain/build.sh --org nordicsemi

# Build `nrfconnect-chip` image for Connected Home over IP applications.
# It is based on `nrfconnect-toolchain` image, but adds a few CHIP dependencies
# and a helper script for collecting sources of NCS and CHIP projects.
./nrfconnect-chip/build.sh --org nordicsemi
```

## Using nrfconnect-chip image

**nrfconnect-chip** image aims to help develop CHIP applications based on nRF Connect SDK. 

[CHIP repository](https://github.com/project-chip/connectedhomeip) comes with a few examples based on nRF Connect SDK. [README](https://github.com/project-chip/connectedhomeip/blob/master/examples/lock-app/nrfconnect/README.md#using-docker-container) file in the *lock-app* example's directory describes how to build, flash and debug the application using the `nrfconnect-chip` image.

NOTES:

* Due to [certain limitations of Docker for MacOS](https://docs.docker.com/docker-for-mac/faqs/#can-i-pass-through-a-usb-device-to-a-container) MacOS users can't use the docker image to interact with nRF hardware. You can still use it to build CHIP applications though.
* New devices may not appear automatically in the container, so restart the container whenever you connect another devkit to your computer.
* `screen` utility is included in the image, so you may use it to attach to the UART interface on your devkit and get access to application logs and Zephyr shell:

        screen /dev/ttyACM0 115200
