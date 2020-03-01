# SocketCAN for GNU/Linux in Ada

This project provides an Ada language binding to SocketCAN for
GNU/Linux systems.

## Motivation

I created this Ada language binding to gain some experience using
SocketCAN on GNU/Linux systems.  I based this implementation upon the
[CAN documentation in the Linux
kernel](https://www.kernel.org/doc/Documentation/networking/can.txt)
and followed the style of the GNAT.Sockets binding.  I did so with the
goal to one day submit it as a patch to the GNAT sources as a
GNU/Linux-specific addition.

## Building

The code in this area may be built using the GNAT project builder
(gprbuild).  To build:

```
cd src
gprbuild
```

## Tests

TODO

## Examples & Documentation

The examples cover what I feel are the most important use-cases of the
SocketCAN feature. These bindings, especially the broadcast manager,
are not comprehensive.  I only coded the features that I thought would
be most useful.  Patches and comments are welcome.

Documentation is limited, but is intentional.  I feel that it's better
to have a trove of examples with a few comments as guidance rather
than API documentation, or worse, soiling the code with [Doxygen
madness](https://blog.codinghorror.com/coding-without-comments/).

This library comes with the following simple examples:

|Directory|Description|
|---|---|
|[simple](examples/simple)|Send and receive raw CAN frames.|
|[streams](examples/streams)|Simple use of Ada streams capability.|
|[filtered_reader](examples/filtered_reader)|Use the kernel to filter inbound CAN messages.|

The Broadcast Manager (BCM) examples:

|Directory|Description|
|---|---|
|[bcm_cyclic_writer](examples/bcm_cyclic_writer)|Use the broadcast manager to send periodic messages.|
|[bcm_filtered_reader](examples/bcm_filtered_reader)|Use the broadcast manager to filter and down-sample incoming messages.|
|[bcm_simple_writer](examples/bcm_simple_writer)|Use the broadcast manager to send individual CAN frames.|

## Using

The Linux kernel must be compiled with support for SocketCAN ("can"
and "can_raw" modules) with a driver for your specific CAN controller
interface.  There is a virtual CAN driver for testing purposes which
can be loaded and created in Linux with the commands below (as root).

```
modprobe can
modprobe can_raw
modprobe vcan
ip link add dev vcan0 type vcan
ip link set up vcan0
ip link show vcan0
```

To build the examples, type the following:

```
cd examples/<subdir>
gprbuild
```

Note: substitute "```<subdir>```" with any of the subdirectory names.

## Authors

* **Glen Cornell** - Initial contribution

## License

This project is licensed under the GNU General Public License - see the [LICENSE.md](LICENSE.md) file for details

## TODO

* Incorporate this as a patch to GCC/GNAT.
