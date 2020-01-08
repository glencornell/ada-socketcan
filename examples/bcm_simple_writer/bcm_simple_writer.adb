with Ada.Text_Io;
with Sockets.Can.Broadcast_Manager;
with Sockets.Can_Frame;
with Interfaces;

procedure Bcm_Simple_Writer is
   If_Name  : constant String := "vcan0";
   Unused_C : Character;
   Bcm      : Sockets.Can.Broadcast_Manager.Broadcast_Manager_Type;
   Frame_1  : constant Sockets.Can_Frame.Can_Frame := 
     (Can_Id   => 16#10#,
      Can_Dlc  => 3,
      Uu_Pad   => 16#FF#,
      Uu_Res0  => 16#FF#,
      Uu_Res1  => 16#FF#,
      Data     => (1 => 16#11#,
		   2 => 16#22#,
		   3 => 16#33#,
		   others => 16#FF#));
   Frame_2  : Sockets.Can_Frame.Can_Frame := 
     (Can_Id   => 16#20#,
      Can_Dlc  => 1,
      Uu_Pad   => 16#FF#,
      Uu_Res0  => 16#FF#,
      Uu_Res1  => 16#FF#,
      Data     => (1 => 16#AA#,
		   others => 16#FF#));
   Frame_3  : constant Sockets.Can_Frame.Can_Frame := 
     (Can_Id   => 16#30#,
      Can_Dlc  => 4,
      Uu_Pad   => 16#FF#,
      Uu_Res0  => 16#FF#,
      Uu_Res1  => 16#FF#,
      Data     => (1 => 16#DE#,
		   2 => 16#AD#,
		   3 => 16#BE#,
		   4 => 16#EF#,
		   others => 16#FF#));
   
   task type T is
      entry Start;
      entry Stop;
   end T;
   task body T is
      use type Interfaces.Unsigned_8;
      I : Interfaces.Unsigned_8 := 255;
      Terminated : Boolean := False;
   begin
      accept Start;
      while not Terminated loop
	 I := I + 1;
	 Frame_2.Data(Frame_2.Data'First) := I;
	 Bcm.Send_Once (Frame_2);
	 select
	    accept Stop do
	       Terminated := True;
	    end Stop;
	 or
	    delay 0.1;
	 end select;
      end loop;
   end T;
   Updater : T;
begin
   Bcm.Create (If_Name);
   Bcm.Send_Periodic (Frame_1, 0.5);
   Bcm.Send_Once (Frame_2);
   Bcm.Send_Once (Frame_3);
   
   Updater.Start;
   
   Ada.Text_Io.Put_Line ("Press any key to stop");
   Ada.Text_Io.Get (Unused_C);
   Updater.Stop;
end Bcm_Simple_Writer;
