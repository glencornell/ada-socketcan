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

package Sockets.Can.Broadcast_Manager is
   
   type Broadcast_Manager_Type is tagged private;
   
   procedure Create (This : out Broadcast_Manager_Type; 
		     Interface_Name : in String);
   --  Object initialization.
   
   function Get_Socket (This : in Broadcast_Manager_Type) return Sockets.Can.Socket_Type;
   --  Socket type accessor
   
   procedure Send_Periodic (This : in Broadcast_Manager_Type;
			    Item : in Sockets.Can_Frame.Can_Frame;
			    Interval : in Duration);
   --  Periodically send the CAN frame at the specified interval.
   
   procedure Send_Once (This : in Broadcast_Manager_Type;
			Item : in Sockets.Can_Frame.Can_Frame);
   --  Send the CAN frame only once.
   
   procedure Update_Periodic (This : in Broadcast_Manager_Type;
			      Item : in Sockets.Can_Frame.Can_Frame);
   --  Change the contents of the CAN frame that is periodically sent.
   
   procedure Stop_Periodic (This : in Broadcast_Manager_Type;
			    Can_Id : in Sockets.Can_Frame.Can_Id_Type);
   --  Delete the cyclic send job of the CAN frame with the specified
   --  CAN ID.
   
   procedure Add_Receive_Filter (This : in Broadcast_Manager_Type;
				 Item : in Sockets.Can_Frame.Can_Frame;
				 Interval : in Duration := 0.0);
   --  Setup the receive filter for the given CAN ID.  Mask is the
   --  content filter - if data changes on the specified mask, the
   --  broadcast manager will send the CAN frame to your socket.  If
   --  the mask is empty, content filtering is disabled and any change
   --  will be forwarded to the receiving socket.  Interval is the
   --  down-sampling inteval.  Down-sampling will reduce the CPU
   --  burden on the application at the expense of dropping all
   --  packets in between intervals.
   
   procedure Remove_Receive_Filter (This : in Broadcast_Manager_Type;
				    Can_Id : in Sockets.Can_Frame.Can_Id_Type);
   --  Remove the receive filter.
   
   procedure Receive_Can_Frame (This : in Broadcast_Manager_Type;
				Frame : out Sockets.Can_Frame.Can_Frame);
   
private
   
   type Broadcast_Manager_Type is tagged record
      Socket : Sockets.Can.Socket_Type;
      Address : Sockets.Can.Sock_Addr_Type;
   end record;
   
end Sockets.Can.Broadcast_Manager;
