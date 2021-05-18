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

with Ada.Strings.Fixed;
with Ada.Text_Io;
with Interfaces;

---------------------
-- Print_Can_Frame --
---------------------

procedure Print_Can_Frame (Frame : in Sockets.Can_Frame.Can_Frame; Prefix : in String := "") is
   package Can_Id_Io is new Ada.Text_Io.Modular_Io (Sockets.Can_Frame.Can_Id_Type);
   package Can_Data_Io is new Ada.Text_Io.Modular_Io (Interfaces.Unsigned_8);
   
   --  Modular_Io.Put (wth a non-decimal base) is represented as
   --  "base#value#".  This function strips away all characters
   --  (including whitespace) away from the value.  Not very
   --  efficient, but this is printing out stuff...
   function Strip (S : String) return String is
      S1 : constant String := Ada.Strings.Fixed.Trim(S, Ada.Strings.Both);
      Start : constant Integer := Ada.Strings.Fixed.Index (S1, "#") + 1;
   begin
      return S1(Start .. S1'Last - 1);
   end Strip;
   
   S : String (1 .. 80);
begin
   -- Print the prefix (if exists):
   if Prefix'Length > 0 then
      Ada.Text_Io.Put (Prefix & " ");
   end if;
   
   -- Print the can ID:
   Can_Id_Io.Put (S, Frame.Can_Id, 16);
   Ada.Text_Io.Put (Strip(S));
   
   -- Print the number of bytes in the payload
   Ada.Text_Io.Put (" [");
   Ada.Text_Io.Put (Ada.Strings.Fixed.Trim(Frame.Can_Dlc'Image, Ada.Strings.Both));
   Ada.Text_Io.Put ("]");
   
   -- Print the payload in hex
   for I in Frame.Data'First .. Frame.Can_Dlc loop
      Ada.Text_Io.Put (" ");
      Can_Data_Io.Put (S, Frame.Data(I), 16);
      Ada.Text_Io.Put (Strip(S));
   end loop;
   Ada.Text_Io.New_Line;
end Print_Can_Frame;
