with Ada.Text_Io;
with Sockets.Can;
with Sockets.Can_Bcm;

procedure Bcm_Cyclic_Writer is
   use type Sockets.Can_Bcm.Flag_Type;
   
   If_Name      : constant String := "vcan0";
   Socket       : Sockets.Can.Socket_Type;
   Address      : Sockets.Can.Sock_Addr_Type;
   
   Capacity     : constant := 3;
   package Bcm is new Sockets.Can_Bcm.Bcm (Capacity => Capacity);
   Msg          : aliased constant Bcm.Msg := 
     (Msg_Head => 
	(Opcode  => Sockets.Can_Bcm.TX_SETUP,
	 Flags   => Sockets.Can_Bcm.SETTIMER or Sockets.Can_Bcm.STARTTIMER,
	 Count   => 0,
	 Ival1   => (0, 0),
	 Ival2   => (0, 2000), -- 2,000 usec period = 500Hz
	 Can_Id  => 16#042#,
	 Nframes => Capacity),
      Frame  => 
	(1 => (Can_Id  => 16#042#,
	       Uu_Pad  => 16#ff#,
	       Uu_Res0 => 16#FF#,
	       Uu_Res1 => 16#FF#,
	       Can_Dlc => 2,
	       Data => 
		 (1 => 16#AA#,
		  2 => 16#BB#,
		  others => 16#ff#)
	      ),
	 2 => (Can_Id  => 16#042#,
	       Uu_Pad  => 16#ff#,
	       Uu_Res0 => 16#FF#,
	       Uu_Res1 => 16#FF#,
	       Can_Dlc => 3,
	       Data => 
		 (1 => 16#11#,
		  2 => 16#22#,
		  3 => 16#33#,
		  others => 16#ff#)
	      ),
	 3 => (Can_Id  => 16#042#,
	       Uu_Pad  => 16#ff#,
	       Uu_Res0 => 16#FF#,
	       Uu_Res1 => 16#FF#,
	       Can_Dlc => 8,
	       Data => 
		 (1 => 16#DE#,
		  2 => 16#AD#,
		  3 => 16#BE#,
		  4 => 16#EF#,
		  5 => 16#DE#,
		  6 => 16#AD#,
		  7 => 16#BE#,
		  8 => 16#EF#)
	      )));
   
   Unused_C : Character;
   
begin
   Sockets.Can.Create_Socket(Socket, 
			     Sockets.Can.Family_Can, 
			     Sockets.Can.Socket_Dgram, 
			     Sockets.Can.Can_Bcm);
   Address.If_Index := Sockets.Can.If_Name_To_Index(If_Name);
   Sockets.Can.Connect_Socket(Socket, Address);
   
   Bcm.Send_Socket(Socket, Msg);
   
   Ada.Text_Io.Put_Line ("Press any key to stop");
   Ada.Text_Io.Get (Unused_C);
   
end Bcm_Cyclic_Writer;
