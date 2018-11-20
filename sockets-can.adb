with Interfaces.C;
with Ada.Io_Exceptions;
with Gnat.Sockets.Thin;
with Gnat.Sockets.Thin_Common;
with Sockets.Os_Constants;
with Sockets.Can_Thin;
with System.Os_Constants;
with System.Crtl;

package body Sockets.Can is
   
   package C renames Interfaces.C;
   use type C.Int;
   use type C.Unsigned;
   
   -- Conversion of Ada typed objects to typeless C types:
   type Family_To_C_Type is array (Family_Type) of C.Int;
   type Mode_To_C_Type is array (Mode_Type) of C.Int;
   type Protocol_To_C_Type is array (Protocol_Type) of C.Int;
   
   Family_To_C : constant Family_To_C_Type :=
     (Family_Can => Sockets.Os_Constants.Af_Can);
   
   Mode_To_C : constant Mode_To_C_Type :=
     (Socket_Dgram => System.Os_Constants.Sock_Dgram,
      Socket_Raw => Sockets.Os_Constants.Sock_Raw);
   
   Protocol_To_C : constant Protocol_To_C_Type :=
     (Can_Raw => Sockets.Os_Constants.Can_Raw,
      Can_Bcm => Sockets.Os_Constants.Can_Bcm);

   -----------------------
   -- Local subprograms --
   -----------------------

   procedure Raise_Socket_Error (Error : Integer);
   --  Raise Socket_Error with an exception message describing the error code
   --  from errno.

   function Err_Code_Image (E : Integer) return String;
   --  Return the value of E surrounded with brackets
   
   ----------------------
   -- If_Name_To_Index --
   ----------------------
   
   function If_Name_To_Index (If_Name : String) return Natural is
      If_Index : C.Unsigned;
   begin
      If_Index := Sockets.Can_Thin.If_Nametoindex(C.To_C(If_Name));
      if If_Index = 0 then
         Raise_Socket_Error (sockets.can_thin.socket_errno);
      end if;
      return Natural (If_Index);
   end If_Name_To_Index;
   
   --------------------------
   -- Enable_CAN_FD_Frames --
   --------------------------
   
   procedure Enable_CAN_FD_Frames
     (Socket : Socket_Type;
      Is_Enabled : Boolean) is
      Res    : C.int;
      Enable : C.Int := (if Is_Enabled then 1 else 0);
   begin
      Res := Gnat.Sockets.Thin.C_Setsockopt
	(S       => C.Int(Gnat.Sockets.To_C(Socket)),
	 Level   => Sockets.Os_Constants.SOL_CAN_RAW,
	 Optname => Sockets.Os_Constants.CAN_RAW_FD_FRAMES,
	 Optval  => Enable'Address,
	 Optlen  => Enable'Size / 8);

      if Res = Gnat.Sockets.Thin_Common.Failure then
         Raise_Socket_Error (Sockets.Can_Thin.Socket_Errno);
	 return;
      end if;
   end Enable_CAN_FD_Frames;
   
   -------------------
   -- Create_Socket --
   -------------------

   procedure Create_Socket
     (Socket   : out Socket_Type;
      Family   : in  Family_Type   := Family_Can;
      Mode     : in  Mode_Type     := Socket_Raw;
      Protocol : in  Protocol_Type := Can_Raw) is 
      Res : C.int;
   begin
      Res := Gnat.Sockets.Thin.C_Socket (Family_To_C(Family), 
					 Mode_To_C(Mode), 
					 Protocol_To_C(Protocol));
      if Res = Gnat.Sockets.Thin_Common.Failure then
         Raise_Socket_Error (Sockets.Can_Thin.Socket_Errno);
	 return;
      end if;
      
      Socket := Gnat.Sockets.To_Ada (Integer(Res));
   end Create_Socket;
   
   --------------------
   -- Connect_Socket --
   --------------------
   
   procedure Connect_Socket
     (Socket  : Socket_Type;
      Address : Sock_Addr_Type) is 
      Res : C.int;
      Addr : aliased Sockets.Can_Thin.Sockaddr_Can;
      Sizeof_Addr : constant C.Int := (Sockets.Can_Thin.Sockaddr_Can'Size + 7) / 8;
   begin
      Addr.Can_Family := Sockets.Os_Constants.Af_Can;
      Addr.Can_Ifindex := C.Unsigned (Address.If_Index);
      Addr.Can_Addr := (Rx_Id => 0, Tx_Id => 0);
      
      Res := Gnat.Sockets.Thin.C_Connect (C.Int(Gnat.Sockets.To_C(Socket)), 
					  Addr'Address, 
					  Sizeof_Addr);
      
      if Res = Gnat.Sockets.Thin_Common.Failure then
         Raise_Socket_Error (sockets.can_thin.socket_errno);
	 return;
      end if;
   end Connect_Socket;
   
   -----------------
   -- Bind_Socket --
   -----------------

   procedure Bind_Socket
     (Socket  : Socket_Type;
      Address : Sock_Addr_Type) is
      Res : C.int;
      Addr : aliased Sockets.Can_Thin.Sockaddr_Can;
      Sizeof_Addr : constant C.Int := (Sockets.Can_Thin.Sockaddr_Can'Size + 7) / 8;
   begin
      Addr.Can_Family := Sockets.Os_Constants.Af_Can;
      Addr.Can_Ifindex := C.Unsigned (Address.If_Index);
      Addr.Can_Addr := (Rx_Id => 0, Tx_Id => 0);
      
      Res := Gnat.Sockets.Thin.C_Bind (C.Int(Gnat.Sockets.To_C(Socket)), 
				       Addr'Address, 
				       Sizeof_Addr);
      
      if Res = Gnat.Sockets.Thin_Common.Failure then
         Raise_Socket_Error (sockets.can_thin.socket_errno);
	 return;
      end if;
   end Bind_Socket;
   
   -------------------
   -- Apply_Filters --
   -------------------
   
   procedure Apply_Filters
     (Socket : Socket_Type;
      Filters : Can_Filter_Array_Type;
      Are_Can_Fd_Frames_Enabled : Boolean := False) is
      Res    : C.int;
   begin
      Res := Gnat.Sockets.Thin.C_Setsockopt
	(S       => C.Int(Gnat.Sockets.To_C(Socket)),
	 Level   => Sockets.Os_Constants.SOL_CAN_RAW,
	 Optname => Sockets.Os_Constants.CAN_RAW_FILTER,
	 Optval  => Filters'Address,
	 Optlen  => Filters'Size / 8);

      if Res = Gnat.Sockets.Thin_Common.Failure then
         Raise_Socket_Error (Sockets.Can_Thin.Socket_Errno);
	 return;
      end if;
      
      Enable_Can_Fd_Frames (Socket, Are_Can_Fd_Frames_Enabled);
   end Apply_Filters;
   
   ----------
   -- Open --
   ----------
   
   function Open (If_Name : String) return Socket_Type is
      Socket : Socket_Type;
      Address : Sock_Addr_Type;
   begin
      Create_Socket(Socket);
      Address.If_Index := If_Name_To_Index(If_Name);
      Bind_Socket(Socket, Address);
      return Socket;
   end Open;
   
   --------------------
   -- Receive_Socket --
   --------------------

   procedure Receive_Socket
     (Socket : Socket_Type;
      Item   : out Sockets.Can_Frame.Can_Frame) is
      Sizeof_Frame : constant Integer := (Sockets.Can_Frame.Can_Frame'Size + 7) / 8;
      Buf : aliased Ada.Streams.Stream_Element_Array (1 .. Ada.Streams.Stream_Element_Offset(Sizeof_Frame));
      for Buf'Address use Item'Address;
      pragma Import (Ada, Buf);
      Unused_Last : Ada.Streams.Stream_Element_Offset;
   begin
      Gnat.Sockets.Receive_Socket(Socket, Buf, Unused_Last);
   end Receive_Socket;
   
   -----------------
   -- Send_Socket --
   -----------------
   
   procedure Send_Socket
     (Socket : Socket_Type;
      Item   : Sockets.Can_Frame.Can_Frame) is
      Sizeof_Frame : constant Integer := (Sockets.Can_Frame.Can_Frame'Size + 7) / 8;
      Buf : aliased Ada.Streams.Stream_Element_Array (1 .. Ada.Streams.Stream_Element_Offset(Sizeof_Frame));
      for Buf'Address use Item'Address;
      pragma Import (Ada, Buf);
      Unused_Last : Ada.Streams.Stream_Element_Offset;
   begin
      Gnat.Sockets.Send_Socket(Socket, Buf, Unused_Last);
   end Send_Socket;
   
   -------------------
   -- Create_Stream --
   -------------------

   procedure Create_Stream (Stream : in out Can_Stream; Socket : Socket_Type) is
   begin
      Stream.Socket       := Socket;
      Stream.Read_Offset  := Read_Buffer_End;
      Stream.Write_Offset := Write_Buffer_First;
   end Create_Stream;
   
   ----------
   -- Open --
   ----------
   
   procedure Open (Stream : in out Can_Stream; If_Name : in String) is
   begin
      Stream.Socket := Open (If_Name);
      Stream.Read_Offset  := Read_Buffer_End;
      Stream.Write_Offset := Write_Buffer_First;
   end Open;
   
   ----------
   -- Read --
   ----------
   
   procedure Read (Stream : in out Can_Stream;
		   Item   : out Ada.Streams.Stream_Element_Array;
		   Last   : out Ada.Streams.Stream_Element_Offset) is
      Requested_Size : Ada.Streams.Stream_Element_Offset := Item'Length;
      Remainaing_Size_Of_Read_Buffer : Ada.Streams.Stream_Element_Offset := Stream.Read_Buffer'Last - Stream.Read_Offset + 1;
   begin
      if Remainaing_Size_Of_Read_Buffer <= 0 then
	 Gnat.Sockets.Receive_Socket(Stream.Socket, Stream.Read_Buffer, Remainaing_Size_Of_Read_Buffer);
	 Stream.Read_Offset := Read_Buffer_First;
      end if;
      if Requested_Size > Remainaing_Size_Of_Read_Buffer then
	 Requested_Size := Remainaing_Size_Of_Read_Buffer;
      end if;
      
      Item (Item'First .. Requested_Size) := Stream.Read_Buffer (Stream.Read_Offset .. Stream.Read_Offset + Requested_Size - 1);
      Stream.Read_Offset := Stream.Read_Offset + Requested_Size;
      Last               := Item'First + Requested_Size - 1;
   end Read;
   
   -----------
   -- Write --
   -----------
   
   procedure Write (Stream : in out Can_Stream;
		    Item   : Ada.Streams.Stream_Element_Array) is
      Last : Ada.Streams.Stream_Element_Offset := Stream.Write_Offset + Item'Length - 1;
   begin
      if Last > Write_Buffer_Last then
	 raise Ada.Io_Exceptions.End_Error;
      end if;
      
      Stream.Write_Buffer (Stream.Write_Offset .. Last) := Item;
      Stream.Write_Offset := Stream.Write_Offset + Item'Length;
      if Last = Sizeof_Frame then
	 Gnat.Sockets.Send_Socket (Stream.Socket, Stream.Write_Buffer, Last);
	 Stream.Write_Offset := Write_Buffer_First;
      end if;
   end Write;
   
   ----------------
   -- Flush_Read --
   ----------------
   
   procedure Flush_Read (Stream : in out Can_Stream) is
   begin
      Stream.Read_Offset  := Read_Buffer_End;
   end Flush_Read;
   
   -----------------
   -- Flush_Write --
   -----------------
   
   procedure Flush_Write (Stream : in out Can_Stream) is
      Unused_Last : Ada.Streams.Stream_Element_Offset;
   begin
      if Stream.Write_Offset > Write_Buffer_First then
	 Gnat.Sockets.Send_Socket (Stream.Socket, Stream.Write_Buffer, Unused_Last);
	 Stream.Write_Offset := Write_Buffer_First;
      end if;
   end Flush_Write;

   ------------------------
   -- Raise_Socket_Error --
   ------------------------

   procedure Raise_Socket_Error (Error : Integer) is
   begin
      raise Socket_Error with
        Err_Code_Image (Error) & Sockets.Can_Thin.Socket_Error_Message (Error);
   end Raise_Socket_Error;

   --------------------
   -- Err_Code_Image --
   --------------------

   function Err_Code_Image (E : Integer) return String is
      Msg : String := E'Img & "] ";
   begin
      Msg (Msg'First) := '[';
      return Msg;
   end Err_Code_Image;
   
   package body Bcm is
      
      use type System.Crtl.Size_T;
      use type System.Crtl.Ssize_T;
      
      -----------------
      -- Send_Socket --
      -----------------
      
      procedure Send_Socket (Socket : in Socket_Type; Item : aliased Msg)
      is
	 Res  : System.Crtl.Ssize_T;
      begin
	 Res := System.Crtl.Write
	   (System.Crtl.Int (Gnat.Sockets.To_C(Socket)),
	    Item'Address,
	    (Bcm.Msg'Size + 7) / 8);
	 
	 if Res = System.Crtl.Ssize_T(Gnat.Sockets.Thin_Common.Failure) then
	    Raise_Socket_Error (Sockets.Can_Thin.Socket_Errno);
	 end if;
      end Send_Socket;
      
      --------------------
      -- Receive_Socket --
      --------------------
      
      procedure Receive_Socket (Socket : in Socket_Type; Item : aliased in out Msg) is
	 Res  : System.Crtl.Ssize_T;
      begin
	 Res := System.Crtl.Read
	   (System.Crtl.Int (Gnat.Sockets.To_C(Socket)),
	    Item'Address,
	    (Bcm.Msg'Size + 7) / 8);
	 
	 if Res = System.Crtl.Ssize_T(Gnat.Sockets.Thin_Common.Failure) then
	    Raise_Socket_Error (Sockets.Can_Thin.Socket_Errno);
	 end if;
      end Receive_Socket;

   end Bcm;

end Sockets.Can;
