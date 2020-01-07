# Simple SocketCAN Example

This is the most basic example: a CAN reader and a writer.
Simple_Writer_2 is another example that initializes the socket using
the primitive Ada SocketCAN API.

* ```simple_writer``` writes one CAN frame to interface vcan0. This
program calls the convenience subprogram ```Sockets.Can.Open()``` to
create and bind to the socket.

* ```simple_writer_2``` does the same as above, but it creates the
socket manually.

* ```simple_reader``` prints out all CAN frames received on interface
vcan0.
