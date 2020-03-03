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

procedure Simple_Writer_2 is
   Socket       : Sockets.Can.Socket_Type;
   Address      : Sockets.Can.Sock_Addr_Type;
   Frame        : Sockets.Can_Frame.Can_Frame;
begin
   Sockets.Can.Create_Socket(Socket);
   Address.If_Index := Sockets.Can.If_Name_To_Index("vcan0");
   Sockets.Can.Bind_Socket(Socket, Address);
   
   frame.can_id  := 16#123#;
   frame.can_dlc := 2;
   frame.Data(1) := 16#11#;
   frame.Data(2) := 16#22#;
   
   Sockets.Can.Send_Socket(Socket, Frame);
end Simple_Writer_2;
