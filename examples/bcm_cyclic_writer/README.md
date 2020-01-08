# Broadcast Manager Cyclic Writer

This example uses the thick bindings to the CAN broadcast manager in
the Linux kernel to periodically transmit CAN frames. There are two
benefits to using the broadcast manager to send cyclic messages.
First, the CPU burden is relieved from the user-space application.  It
simply needs to update the CAN frames as system state changes.
Secondly, because the broadcast manager is running as a kernel task,
there is less jitter on the message transmissions.

## Usage

As root, set up the CANbus interface. I'm using the virtual CAN driver
to simplify the test, but you should be able to use any CAN interface.

```
modprobe can
modprobe can_raw
modprobe vcan
ip link add dev vcan0 type vcan
ip link set up vcan0
ip link show vcan0
./bcm_cyclic_writer
```

In another shell, type the following:

```
$ candump vcan0
  vcan0  020   [1]  21
  vcan0  010   [3]  11 22 33
  vcan0  010   [3]  11 22 33
  vcan0  030   [4]  DE AD BE EF
  vcan0  020   [1]  2B
...
```
