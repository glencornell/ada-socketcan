-- MIT License
--
-- Copyright (c) 2021 Glen Cornell <glen.m.cornell@gmail.com>
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.

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
