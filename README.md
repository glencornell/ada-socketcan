# SocketCAN for GNU/Linux in Ada

This project provides a sample implementation of SocketCAN in Ada for
GNU/Linux systems.

## Motivation

In order to get familiar with SocketCAN on GNU/Linux systems, I
created an implementation in Ada based upon the CAN documentation in
the Linux kernel and several examples in C on the internet.

## Building

The code in this area may be built using the GNAT project builder
(gprbuild).  To build:

'''
gprbuild
'''

Note that the compiler will issue several warnings indicating that
some internal or OS-specific packages are being used.  The warnings
may be safely ignored when compiling for a GNU/Linux system.

## TODO

* Create better documentation
* Create more realistic examples
* Fix bcm_simple_reader - the BCM reader doesn't work as I thought
* Incorporate this as a patch to GCC/GNAT.
