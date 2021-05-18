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
