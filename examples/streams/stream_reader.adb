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

with Sockets.Can;
with Sockets.Can_Frame;
with Print_Can_Frame;

procedure Stream_Reader is
   Socket       : Sockets.Can.Socket_Type;
   Can_Stream   : aliased Sockets.Can.Can_Stream;
   Frame        : Sockets.Can_Frame.Can_Frame;
   If_Name      : constant String := "vcan0";
begin
   Socket := Sockets.Can.Open(If_Name);
   Sockets.Can.Create_Stream (Can_Stream, Socket);
   
   loop 
      Sockets.Can_Frame.Can_Frame'Read (Can_Stream'Access, Frame);
      Print_Can_Frame (Frame, If_Name);
   end loop;
end Stream_Reader;
