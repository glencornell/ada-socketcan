--  Copyright (C) 2020 Glen Cornell <glen.m.cornell@gmail.com>
--  
--  This program is free software: you can redistribute it and/or
--  modify it under the terms of the GNU General Public License as
--  published by the Free Software Foundation, either version 3 of the
--  License, or (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
--  General Public License for more details.
--
--  You should have received a copy of the GNU General Public License
--  along with this program.  If not, see
--  <http://www.gnu.org/licenses/>.

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
