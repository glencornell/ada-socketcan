with Sockets.Can;
with Sockets.Can_Bcm;

procedure Bcm_Simple_Writer is
   Socket       : Sockets.Can.Socket_Type;
   Address      : Sockets.Can.Sock_Addr_Type;
   
   package Bcm is new Sockets.Can.Bcm (Capacity => 1);
   Msg          : aliased constant Bcm.Msg := 
     (Msg_Head => 
	(Opcode => Sockets.Can_Bcm.TX_SEND,
	 Flags  => 0,
	 Count  => 0,
	 Ival1  => (0, 0),
	 Ival2  => (0, 0),
	 Can_Id => 0,
	 Nframes => 1),
      Frame  => 
	(1 => (Can_Id  => 16#123#,
	       Can_Dlc => 2,
	       Uu_Pad  => 16#ff#,
	       Uu_Res0 => 16#FF#,
	       Uu_Res1 => 16#FF#,
	       Data => 
		 (1 => 16#11#,
		  2 => 16#22#,
		  others => 16#ff#)
	      )));
   
begin
   Sockets.Can.Create_Socket(Socket, 
			     Sockets.Can.Family_Can, 
			     Sockets.Can.Socket_Dgram, 
			     Sockets.Can.Can_Bcm);
   Address.If_Index := Sockets.Can.If_Name_To_Index("vcan0");
   Sockets.Can.Connect_Socket(Socket, Address);
   
   -- Set up the receiving filter:
   Bcm.Send_Socket(Socket, Msg);
end Bcm_Simple_Writer;
