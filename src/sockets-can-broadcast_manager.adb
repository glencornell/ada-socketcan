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

with Interfaces.C;
with Sockets.Can_Bcm_Thin;
with Gnat.Sockets;

package body Sockets.Can.Broadcast_Manager is
   
   use type Sockets.Can_Bcm_Thin.Flag_Type;
   
   type Msg_Type is record
      Msg_Head : aliased Sockets.Can_Bcm_Thin.Bcm_Msg_Head;
      Frame : aliased Sockets.Can_Frame.Can_Frame;
   end record;
   pragma Convention (C_Pass_By_Copy, Msg_Type);

   
   procedure Create (This: out Broadcast_Manager_Type; 
		     Interface_Name : in String) is
   begin
      Sockets.Can.Create_Socket(This.Socket, 
				Sockets.Can.Family_Can, 
				Sockets.Can.Socket_Dgram, 
				Sockets.Can.Can_Bcm);
      This.Address.If_Index := If_Name_To_Index(Interface_Name);
      Sockets.Can.Connect_Socket(This.Socket, This.Address);
   end Create;
   
   function Get_Socket (This : in Broadcast_Manager_Type) return Sockets.Can.Socket_Type is
   begin
      return This.Socket;
   end Get_Socket;
   
   function To_Timeval (D : in Duration) return Sockets.Can_Bcm_Thin.Timeval is
      pragma Unsuppress (Overflow_Check);
      Secs       : Duration;
      Micro_Secs : Duration;
      
      Micro      : constant := 1_000_000;
      Rval       : Sockets.Can_Bcm_Thin.Timeval;
   begin
      --  Seconds extraction, avoid potential rounding errors
      Secs   := D - 0.5;
      Rval.tv_sec := Interfaces.C.Long (Secs);
      
      --  Microseconds extraction
      Micro_Secs := D - Duration (Rval.tv_sec);
      Rval.tv_usec := Interfaces.C.Long (Micro_Secs * Micro);
      
      return Rval;
   end To_Timeval;
   
   procedure Send_Socket (Socket : Sockets.Can.Socket_Type;
			  Item   : aliased Msg_Type) is
      Sizeof_Item : constant Integer := (Msg_Type'Size + 7) / 8;
      Buf : aliased Ada.Streams.Stream_Element_Array (1 .. Ada.Streams.Stream_Element_Offset(Sizeof_Item));
      for Buf'Address use Item'Address;
      pragma Import (Ada, Buf);
      Unused_Last : Ada.Streams.Stream_Element_Offset;
   begin
      Gnat.Sockets.Send_Socket(Socket, Buf, Unused_Last);
   end Send_Socket;
   
   procedure Receive_Socket
     (Socket : Sockets.Can.Socket_Type;
      Item   : aliased out Msg_Type) is
      Sizeof_Item : constant Integer := (Msg_Type'Size + 7) / 8;
      Buf : aliased Ada.Streams.Stream_Element_Array (1 .. Ada.Streams.Stream_Element_Offset(Sizeof_Item));
      for Buf'Address use Item'Address;
      pragma Import (Ada, Buf);
      Unused_Last : Ada.Streams.Stream_Element_Offset;
   begin
      Gnat.Sockets.Receive_Socket(Socket, Buf, Unused_Last);
   end Receive_Socket;
   
   procedure Send_Periodic (This : in Broadcast_Manager_Type;
			    Item : in Sockets.Can_Frame.Can_Frame;
			    Interval : in Duration) is
      Msg : aliased constant Msg_Type := 
	(Msg_Head => (Opcode  => Sockets.Can_Bcm_Thin.Tx_Setup,
	              Flags   => Sockets.Can_Bcm_Thin.SETTIMER or 
			         Sockets.Can_Bcm_Thin.STARTTIMER,
		      Count   => 0,
		      Ival1   => (Tv_Sec  => 0, Tv_Usec => 0),
		      Ival2   => To_Timeval (Interval),
		      Can_Id  => Item.Can_Id,
		      Nframes => 1),
	 Frame => Item);
   begin
      Send_Socket(This.Socket, Msg);
   end Send_Periodic;
   
   procedure Send_Once (This : in Broadcast_Manager_Type;
			Item : in Sockets.Can_Frame.Can_Frame) is
      Msg : aliased constant Msg_Type := 
	(Msg_Head => (Opcode  => Sockets.Can_Bcm_Thin.Tx_Send,
	              Flags   => 0,
		      Count   => 0,
		      Ival1   => (Tv_Sec  => 0, Tv_Usec => 0),
		      Ival2   => (Tv_Sec  => 0, Tv_Usec => 0),
		      Can_Id  => Item.Can_Id,
		      Nframes => 1),
	 Frame => Item);
   begin
      Send_Socket(This.Socket, Msg);
   end Send_Once;
   
   procedure Update_Periodic (This : in Broadcast_Manager_Type;
			      Item : in Sockets.Can_Frame.Can_Frame) is
      Msg : aliased constant Msg_Type := 
	(Msg_Head => (Opcode  => Sockets.Can_Bcm_Thin.Tx_Setup,
	              Flags   => 0,
		      Count   => 0,
		      Ival1   => (Tv_Sec  => 0, Tv_Usec => 0),
		      Ival2   => (Tv_Sec  => 0, Tv_Usec => 0),
		      Can_Id  => Item.Can_Id,
		      Nframes => 1),
	 Frame => Item);
   begin
      Send_Socket(This.Socket, Msg);
   end Update_Periodic;
   
   procedure Stop_Periodic (This : in Broadcast_Manager_Type;
			    Can_Id : in Sockets.Can_Frame.Can_Id_Type) is
      Msg : aliased constant Msg_Type := 
	(Msg_Head => (Opcode  => Sockets.Can_Bcm_Thin.Tx_Delete,
	              Flags   => 0,
		      Count   => 0,
		      Ival1   => (Tv_Sec  => 0, Tv_Usec => 0),
		      Ival2   => (Tv_Sec  => 0, Tv_Usec => 0),
		      Can_Id  => Can_Id,
		      Nframes => 1),
	 Frame => (Can_Id  => Can_Id,
		   Uu_Pad  => 16#FF#,
		   Uu_Res0 => 16#FF#,
		   Uu_Res1 => 16#FF#,
		   Can_Dlc => 0,
		   Data => (others => 16#FF#)));
   begin
      Send_Socket(This.Socket, Msg);
   end Stop_Periodic;
   
   procedure Add_Receive_Filter (This : in Broadcast_Manager_Type;
				 Item : in Sockets.Can_Frame.Can_Frame;
				 Interval : in Duration := 0.0) is
      Msg : aliased constant Msg_Type := 
	(Msg_Head => (Opcode  => Sockets.Can_Bcm_Thin.Rx_Setup,
	              Flags   => Sockets.Can_Bcm_Thin.SETTIMER,
		      Count   => 0,
		      Ival1   => (Tv_Sec  => 0, Tv_Usec => 0),
		      Ival2   => To_Timeval(Interval),
		      Can_Id  => Item.Can_Id,
		      Nframes => 1),
	 Frame => Item);
   begin
      Send_Socket(This.Socket, Msg);
   end Add_Receive_Filter;
   
   procedure Remove_Receive_Filter (This : in Broadcast_Manager_Type;
				    Can_Id : in Sockets.Can_Frame.Can_Id_Type) is
      Msg : aliased constant Msg_Type := 
	(Msg_Head => (Opcode  => Sockets.Can_Bcm_Thin.Rx_Delete,
	              Flags   => 0,
		      Count   => 0,
		      Ival1   => (Tv_Sec  => 0, Tv_Usec => 0),
		      Ival2   => (Tv_Sec  => 0, Tv_Usec => 0),
		      Can_Id  => Can_Id,
		      Nframes => 1),
	 Frame => (Can_Id  => Can_Id,
		   Uu_Pad  => 16#FF#,
		   Uu_Res0 => 16#FF#,
		   Uu_Res1 => 16#FF#,
		   Can_Dlc => 0,
		   Data => (others => 16#FF#)));
   begin
      Send_Socket(This.Socket, Msg);
   end Remove_Receive_Filter;
   
   procedure Receive_Can_Frame (This : in Broadcast_Manager_Type;
				Frame : out Sockets.Can_Frame.Can_Frame) is
      Msg : aliased Msg_Type;
   begin
      Receive_Socket(This.Socket, Msg);
      Frame := Msg.Frame;
   end Receive_Can_Frame;
   
end Sockets.Can.Broadcast_Manager;
