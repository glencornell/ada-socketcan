# Broadcast Manager Filtered Reader

This example uses the thick bindings to the CAN broadcast manager in
the Linux kernel to perform content filtering of inbound CAN frames.

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
```

In a shell, type the following command to generate random
traffic. Unless this happens to generate can_ids 0x20 or 0x30, this
traffic will all be filtered away by the BCM:

```
cangen vcan0
```

In another shell, type the following command to generate specific CAN
frames needed by our reader example:

```
cd ../examples/bcm_cyclic_writer
./bcm_cyclic_writer
```

Finally, run the example.  It will ask the BCM to filter all inbound
CAN frames except can_id 0x20 & 0x30.  In both cases, content
filtering is set up to look for changes in the first byte.

```
./bcm_filtered_reader
```

You should see the following output:

```
Press any key to stop
30 [4] DE AD BE EF
20 [1] 86
20 [1] 90
20 [1] 9A
```

