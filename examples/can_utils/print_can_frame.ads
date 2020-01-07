with Sockets.Can_Frame;

procedure Print_Can_Frame (Frame : in Sockets.Can_Frame.Can_Frame; Prefix : in String := "");
--  Print the raw CAN frame to ada.text_io.current_output.  The string
--  specified by the parameter "Prefix" is printed out on the same
--  line just before the can frame.  Prefix can be anything that you
--  want, but it is recommended that you use the interface name from
--  which the frame was received.  Output is in the format similar to
--  the candump utility. Examples:
--
--  vcan0 52 [5] 10 22 9A 69 E4
--  vcan0 4D6 [8] 56 3C 4F 78 23 19 B 4F
--  vcan0 6BD [8] 29 87 AA 2D 26 1B 33 1D
--  vcan0 E [8] 4B F 79 67 60 D0 C0 5
--  vcan0 269 [1] 4A
--  vcan0 DF [2] AF 2
--  vcan0 13E [4] 3A 93 5 58
