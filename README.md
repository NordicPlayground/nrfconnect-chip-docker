# nRF Connect SDK: nrfconnect-chip-docker

This repository contains definition of `nrfconnect-chip` docker image which may come in handy during development of CHIP applications based on nRF Connect SDK (NCS).

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

* The image contains also `dbus`, `wpantund` and the NCP firmware, so you can easily set up the OpenThread NCP solution on a nRF52840 DK:
        
        # Get serial numbers of connected DKs
        nrfjprog -i
        # Flash NCP onto the desired DK
        nrfjprog -s <DK-serial-number> --program /opt/ncp_4.0.0_pca10056.hex --chiperase --reset
        # Start wpantund (in case /dev/ttyACM0 is serial interface of the DK)
        service dbus start
        wpantund -s /dev/ttyACM0 -b 115200 &
        wpanctl
        # ... now use wpanctl commands to connect to the Thread network

