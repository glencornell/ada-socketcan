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

--  SETUP:
--
--  The Linux kernel must be compiled with support for SocketCAN
--  ("can" and "can_raw" modules) with a driver for your specific CAN
--  controller interface.  There is a virtual CAN driver for testing
--  purposes which can be loaded and created in Linux with the
--  commands below.
--
--  $ modprobe can
--  $ modprobe can_raw
--  $ modprobe vcan
--  $ sudo ip link add dev vcan0 type vcan
--  $ sudo ip link set up vcan0
--  $ ip link show vcan0
--  3: vcan0: <NOARP,UP,LOWER_UP> mtu 16 qdisc noqueue state UNKNOWN 
--      link/can
--
--  EXAMPLES:
--
--  The following code snippet is a working example of the SocketCAN
--  API that sends a packet using the raw interface. It is based on
--  the notes documented in the Linux Kernel.
--
--  with Gnat.Sockets;
--  with Sockets.Can;
--  with Sockets.Can_Frame;
--  procedure Socketcan_Test is
--     Socket       : Sockets.Can.Socket_Type;
--     Address      : Sockets.Can.Sock_Addr_Type;
--     Frame        : Sockets.Can_Frame.Can_Frame;
--  begin
--     Sockets.Can.Create_Socket(Socket);
--     Address.If_Index := Sockets.Can.If_Name_To_Index("vcan0");
--     Sockets.Can.Bind_Socket(Socket, Address);
--     frame.can_id  := 16#123#;
--     frame.can_dlc := 2;
--     frame.Data(0) := 16#11#;
--     frame.Data(1) := 16#22#;
--     Sockets.Can.Send_Socket(Socket, Frame);
--  end Socketcan_Test;
--
--  The packet can be analyzed on the vcan0 interface using the
--  candump utility which is part of the SocketCAN can-utils package.
--  On another shell, type the following command to view the output of
--  the program ablve.
--
--  $ candump vcan0
--    vcan0  123  [2] 11 22

with Ada.Streams;
with Gnat.Sockets;
with Sockets.Can_Frame;

package Sockets.Can is
   
   subtype Socket_Type is Gnat.Sockets.Socket_Type;
   --  Sockets are used to implement a reliable bi-directional
   --  point-to-point, datagram-based connection between
   --  hosts.
   
   subtype Request_Flag_Type is Gnat.Sockets.Request_Flag_Type;
   No_Request_Flag : constant Request_Flag_Type := Gnat.Sockets.No_Request_Flag;

   Socket_Error : exception;
   --  There is only one exception in this package to deal with an error during
   --  a socket routine. Once raised, its message contains a string describing
   --  the error code.

   type Family_Type is (Family_Can);
   --  Address family (or protocol family) identifies the
   --  communication domain and groups protocols with similar address
   --  formats.  This is represented as the "domain" parameter in the
   --  socket(2) man page.

   type Mode_Type is (Socket_Dgram, Socket_Raw);
   
   type Protocol_Type is (Can_Raw, Can_Bcm);
   
   type Sock_Addr_Type (Family : Family_Type := Family_Can) is record
      case Family is
	 when Family_Can =>
	    If_Index : Natural := 0;
      end case;
   end record;
   --  Socket addresses fully define a socket connection with protocol family,
   --  an Internet address and a port.
   
   -- CAN ID based filter in can_register().
   -- Description:
   --   A filter matches, when
   --  
   --            <received_can_id> & mask == can_id & mask
   --  
   --   The filter can be inverted (CAN_INV_FILTER bit set in can_id) or it can
   --   filter for error message frames (CAN_ERR_FLAG bit set in mask).
   type Can_Filter is record
      Can_Id   : aliased Can_Frame.Can_Id_Type;  -- relevant bits of CAN ID which are not masked out.
      Can_Mask : aliased Can_Frame.Can_Id_Type;  -- CAN mask (see description)
   end record;
   type Can_Filter_Array_Type is array (Positive range <>) of Can_Filter;

   function If_Name_To_Index (If_Name : String) return Natural;
   --  Return the index for the given interface name.  Raises
   --  Socket_Error on error.
   
   procedure Create_Socket
     (Socket   : out Socket_Type;
      Family   : in  Family_Type   := Family_Can;
      Mode     : in  Mode_Type     := Socket_Raw;
      Protocol : in  Protocol_Type := Can_Raw);
   --  Create an endpoint for communication. Raises Socket_Error on error
   
   procedure Bind_Socket
     (Socket  : Socket_Type;
      Address : Sock_Addr_Type);
   --  Once a socket is created, assign a local address to it. Raise
   --  Socket_Error on error.
   
   procedure Connect_Socket
     (Socket  : Socket_Type;
      Address : Sock_Addr_Type);
   --  Connect to a SOCK_DGRAM CAN socket. Raise Socket_Error on
   --  error.
   
   function Open (If_Name : String) return Socket_Type;
   --  Convenience routine to create a socket and bind to a named
   --  interface (eg: "can0").  This is the same as the following code
   --  segment:
   --     Sockets.Can.Create_Socket(Socket);
   --     Address.If_Index := Sockets.Can.If_Name_To_Index("vcan0");
   --     Sockets.Can.Bind_Socket(Socket, Address);
   --     return Socket;
      
   procedure Receive_Socket
     (Socket : Socket_Type;
      Item   : out Sockets.Can_Frame.Can_Frame);
   --  Convenience routine to receive a raw CAN frame from
   --  Socket. Raise Socket_Error on error.
   
   procedure Send_Socket
     (Socket : Socket_Type;
      Item   : Sockets.Can_Frame.Can_Frame);
   --  Convenience routine to transmit a raw CAN frame over a socket.
   --  Raises Socket_Error on any detected error condition.
   
   procedure Apply_Filters
     (Socket : Socket_Type;
      Filters : Can_Filter_Array_Type;
      Are_Can_Fd_Frames_Enabled : Boolean := False);
   --  Ask the kernel to filter inbound CAN packets on a given socket
   --  (family_can, socket_raw) according to the supplied list.
   --  Additionally, tell the kernel that you want to receive CAN FD
   --  frames that match the given filters.
      
   type Can_Stream is new Ada.Streams.Root_Stream_Type with private;
   
   procedure Create_Stream (Stream : in out Can_Stream; Socket : Socket_Type);
   --  Initialize the stream to the created socket.
   
   procedure Open (Stream : in out Can_Stream; If_Name : in String);
   --  Convenience routine to open a socketcan socket, bind to the raw
   --  interface and create a can_stream object.
   
   procedure Read (Stream : in out Can_Stream;
		   Item   : out Ada.Streams.Stream_Element_Array;
		   Last   : out Ada.Streams.Stream_Element_Offset);
   --  Read data from the stream
   
   procedure Write (Stream : in out Can_Stream;
		    Item   : Ada.Streams.Stream_Element_Array);
   --  Write data to the stream
   
   procedure Flush_Read (Stream : in out Can_Stream);
   --  Reset the read buffer
   
   procedure Flush_Write (Stream : in out Can_Stream);
   --  Send anything in the write buffer and reset it.  If the write
   --  buffer is empty, then no message is written to the CAN
   --  interface.
   
   procedure Raise_Socket_Error (Error : Integer);
   --  Raise Socket_Error with an exception message describing the
   --  error code from errno.

   function Err_Code_Image (E : Integer) return String;
   --  Return the value of E surrounded with brackets
   
private
   
   pragma No_Component_Reordering (Sock_Addr_Type);
   pragma Convention (C_Pass_By_Copy, Can_Filter);
   pragma Convention (C, Can_Filter_Array_Type);
   
   use type Ada.Streams.Stream_Element_Offset;
   
   Sizeof_Frame       : constant Ada.Streams.Stream_Element_Offset := (Sockets.Can_Frame.Can_Frame'Size + 7) / 8;
   
   Read_Buffer_First  : constant Ada.Streams.Stream_Element_Offset := 1;
   Read_Buffer_Last   : constant Ada.Streams.Stream_Element_Offset := Sizeof_Frame;
   
   Write_Buffer_First : constant Ada.Streams.Stream_Element_Offset := 1;
   Write_Buffer_Last  : constant Ada.Streams.Stream_Element_Offset := Sizeof_Frame;
   
   --  Read_Buffer_End is a sentinel one stream element beyond the
   --  last element in the buffer, when the read_offset is set to
   --  this, then the read_buffer is empty and we need to read another
   --  CAN frame.
   Read_Buffer_End : constant Ada.Streams.Stream_Element_Offset := Read_Buffer_Last + 1;

   type Can_Stream is new Ada.Streams.Root_Stream_Type with record
      Socket       : Socket_Type := Gnat.Sockets.No_Socket;
      
      Read_Buffer  : aliased Ada.Streams.Stream_Element_Array (Read_Buffer_First .. Read_Buffer_Last);
      Read_Offset  : Ada.Streams.Stream_Element_Offset := Read_Buffer_End;
      
      Write_Buffer : aliased Ada.Streams.Stream_Element_Array (Write_Buffer_First .. Write_Buffer_Last);
      Write_Offset : Ada.Streams.Stream_Element_Offset := Write_Buffer_First;
   end record;

end Sockets.Can;
