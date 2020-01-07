# SocketCAN Example Using Filters

This is a simple example using socketcan's filtering feature to help
reduce CPU load.  In this example, the application creates an array of
CAN IDs that it's interested in.  The kernel will only pass incoming
CAN frames to the application that matches the filters. To demonstrate
this capability, compile and run this application.  In another shell,
generate a random workload on vcan0:

```
cangen vcan0
```

In another shell, now send specific can messages that match the
filter:

```
cansend vcan0 110#11.22.33
cansend vcan0 0A0#AA.BB.CC
cansend vcan0 320#DEADBEEF
```

You then see the following output for this program:

```
Got 16#110#
Got 16#0A0#
Got 16#320#
```
