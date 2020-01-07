# SocketCAN for GNU/Linux in Ada

This project provides an Ada language binding to SocketCAN for
GNU/Linux systems.

## Motivation

In order to get familiar with SocketCAN on GNU/Linux systems, I
created an Ada language binding.  I based this implementation upon the
(CAN documentation in the Linux kernel)[https://www.kernel.org/doc/Documentation/networking/can.txt] and followed the style of the
GNAT.Sockets binding.

## Building

The code in this area may be built using the GNAT project builder
(gprbuild).  To build:

```
cd src
gprbuild
```

## Tests

TODO

## Examples

The Linux kernel must be compiled with support for SocketCAN ("can"
and "can_raw" modules) with a driver for your specific CAN controller
interface.  There is a virtual CAN driver for testing purposes which
can be loaded and created in Linux with the commands below.

```
$ modprobe can
$ modprobe can_raw
$ modprobe vcan
$ sudo ip link add dev vcan0 type vcan
$ sudo ip link set up vcan0
$ ip link show vcan0
3: vcan0: <NOARP,UP,LOWER_UP> mtu 16 qdisc noqueue state UNKNOWN 
    link/can
```

To build the examples, type the following:

```
cd examples/<subdir>
gprbuild
```

Note: substitute "<subdir>" with any of the subdirectory names.

## Authors

* **Glen Cornell** - Initial contribution

## License

This project is licensed under the GNU General Public License - see the [LICENSE.md](LICENSE.md) file for details

## TODO

* Create better documentation
* Create more realistic examples
* Fix bcm_simple_reader - the BCM reader doesn't work as I thought
* Incorporate this as a patch to GCC/GNAT.
