# Broadcast Manager Simple Writer

This example uses the thick bindings to the CAN broadcast manager in
the Linux kernel to transmit CAN frames one at a time.  When using the
broadcast manager, it is sometimes desirable to send only one CAN
frame.  On a broadcast manager (SOCK_DGRAM) protocol, one cannot use
write() or sendto() to send CAN frames as one does with the raw CAN
protocol family (SOCK_RAW).  This example shows you how to send
individual frames while using the CAN broadcast manager.

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
./bcm_simple_writer
```

In another shell, type the following:

```
$ candump vcan0
  vcan0  010   [3]  11 22 33
  vcan0  020   [1]  AA
  vcan0  030   [4]  DE AD BE EF
  vcan0  020   [1]  00
  vcan0  020   [1]  01
  vcan0  020   [1]  02
  vcan0  020   [1]  03
  vcan0  020   [1]  04
  vcan0  010   [3]  11 22 33
  vcan0  020   [1]  05
...
```

Notice that in this example, you'll see can_ids 0x10 and 0x20 repeat
indefinitely, while can_id 0x30 appears only once.  Can_id 0x10 is
managed cyclicaly by the broadcast manager using Bcm.Send_Periodoc(),
while can_id 0x20 is managed by the application in a loop using
Bcm.Send_Once().  Finally can_id 0x30 is sent only once with
Bcm.Send_Once().

