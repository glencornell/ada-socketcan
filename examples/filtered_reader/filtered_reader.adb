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

--  This is a simple example using socketcan's filtering feature to
--  help reduce CPU load.  In this example, the application creates an
--  array of CAN IDs that it's interested in.  The kernel will only
--  pass incoming CAN frames to the application that matches the
--  filters. To demonstrate this capability, compile and run this
--  application.  In another shell, generate a random workload on
--  vcan0:
--
--  cangen vcan0
--
--  In another shell, now send specific can messages that match the
--  filter:
--
--  cansend vcan0 110#11.22.33
--  cansend vcan0 0A0#AA.BB.CC
--  cansend vcan0 320#DEADBEEF
--
--  You then see the following output for this program:
--
--  Got 16#110#
--  Got 16#0A0#
--  Got 16#320#


with Ada.Text_Io;
with Sockets.Os_Constants;
with Sockets.Can;
with Sockets.Can_Frame;
with Print_Can_Frame;

procedure Filtered_Reader is
   Socket       : Sockets.Can.Socket_Type;
   Frame        : Sockets.Can_Frame.Can_Frame;
   If_Name      : constant String := "vcan0";
   Filters      : constant Sockets.Can.Can_Filter_Array_Type := 
     ((Can_Id => 16#0A0#, Can_Mask => Sockets.Os_Constants.CAN_SFF_MASK),
      (Can_Id => 16#110#, Can_Mask => Sockets.Os_Constants.CAN_SFF_MASK),
      (Can_Id => 16#320#, Can_Mask => Sockets.Os_Constants.CAN_SFF_MASK));
   
   procedure Process_Frame (Frame : in Sockets.Can_Frame.Can_Frame; If_Name : in String) is
   begin
      case Frame.Can_Id is
	 when 16#0A0# =>
	    Ada.Text_Io.Put_Line ("Got 16#0A0#");
	 when 16#110# =>
	    Ada.Text_Io.Put_Line ("Got 16#110#");
	 when 16#320# =>
	    Ada.Text_Io.Put_Line ("Got 16#320#");
	 when others =>
	    Ada.Text_Io.Put ("Received unexpected CAN frame: ");
	    Print_Can_Frame (Frame, If_Name);
      end case;
   end Process_Frame;
   
begin
   Socket := Sockets.Can.Open(If_Name);
   Sockets.Can.Apply_Filters (Socket, Filters, True);
   loop 
      Sockets.Can.Receive_Socket(Socket, Frame);
      Process_Frame (Frame, If_Name);
   end loop;
end Filtered_Reader;
