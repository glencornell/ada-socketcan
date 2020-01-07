with Ada.Text_Io;
with Sockets.Can;
with Sockets.Can_Bcm;
with Sockets.Can_Frame;
with Print_Can_Frame;

procedure Bcm_Simple_Reader is
   If_Name      : constant String := "vcan0";
   Socket       : Sockets.Can.Socket_Type;
   Address      : Sockets.Can.Sock_Addr_Type;
   
   Capacity     : constant := 3;
   package Bcm is new Sockets.Can.Bcm (Capacity => Capacity);
   Msg          : aliased Bcm.Msg := 
     (Msg_Head => 
	(Opcode  => Sockets.Can_Bcm.RX_SETUP,
	 Flags   => 0,
	 Count   => 0,
	 Ival1   => (0, 0),
	 Ival2   => (0, 0),
	 Can_Id  => 0,
	 Nframes => Capacity),
      Frame  => 
	(1 => (Can_Id  => 16#0A0#,
	       Uu_Pad  => 16#ff#,
	       Uu_Res0 => 16#FF#,
	       Uu_Res1 => 16#FF#,
	       Can_Dlc => 2,
	       Data => 
		 (1 => 16#11#,
		  2 => 16#22#,
		  others => 16#ff#)
	      ),
	 2 => (Can_Id  => 16#110#,
	       Uu_Pad  => 16#ff#,
	       Uu_Res0 => 16#FF#,
	       Uu_Res1 => 16#FF#,
	       Can_Dlc => 2,
	       Data => 
		 (1 => 16#11#,
		  2 => 16#22#,
		  others => 16#ff#)
	      ),
	 3 => (Can_Id  => 16#320#,
	       Uu_Pad  => 16#ff#,
	       Uu_Res0 => 16#FF#,
	       Uu_Res1 => 16#FF#,
	       Can_Dlc => 2,
	       Data => 
		 (1 => 16#11#,
		  2 => 16#22#,
		  others => 16#ff#)
	      )));
   
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
   Sockets.Can.Create_Socket(Socket, 
			     Sockets.Can.Family_Can, 
			     Sockets.Can.Socket_Dgram, 
			     Sockets.Can.Can_Bcm);
   Address.If_Index := Sockets.Can.If_Name_To_Index(If_Name);
   Sockets.Can.Connect_Socket(Socket, Address);
   Bcm.Send_Socket(Socket, Msg);
   
   loop 
      Msg.Msg_Head.Opcode  := Sockets.Can_Bcm.TX_READ;
      Msg.Msg_Head.Can_Id  := 16#042#;
      Msg.Msg_Head.Nframes := 0;
      Bcm.Send_Socket(Socket, Msg);
      
      Bcm.Receive_Socket(Socket, Msg);
      for I in 1 .. Msg.Msg_Head.Nframes loop
	 Process_Frame (Msg.Frame(I), If_Name);
      end loop;
   end loop;
end Bcm_Simple_Reader;
