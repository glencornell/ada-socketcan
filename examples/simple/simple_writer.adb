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

with Sockets.Can;
with Sockets.Can_Frame;
with Create_Can_Frame;

procedure Simple_Writer is
   Socket       : Sockets.Can.Socket_Type;
   Frame        : constant Sockets.Can_Frame.Can_Frame :=
     Create_Can_Frame (Can_Id => 16#123#,
		       Data   => (16#11#, 16#22#, 16#33#));
begin
   Socket := Sockets.Can.Open("vcan0");
   Sockets.Can.Send_Socket(Socket, Frame);
end Simple_Writer;
