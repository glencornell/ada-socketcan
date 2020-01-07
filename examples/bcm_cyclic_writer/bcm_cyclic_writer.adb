with Ada.Text_Io;
with Sockets.Can.Broadcast_Manager;
with Sockets.Can_Frame;

procedure Bcm_Cyclic_Writer is
   If_Name  : constant String := "vcan0";
   Unused_C : Character;
   Bcm      : Sockets.Can.Broadcast_Manager.Broadcast_Manager_Type;
   Frame_1  : constant Sockets.Can_Frame.Can_Frame := 
     (Can_Id   => 16#42#,
      Can_Dlc  => 3,
      Uu_Pad   => 16#FF#,
      Uu_Res0  => 16#FF#,
      Uu_Res1  => 16#FF#,
      Data     => (1 => 16#11#,
		   2 => 16#22#,
		   3 => 16#33#,
		   others => 16#FF#));
   Frame_2  : constant Sockets.Can_Frame.Can_Frame := 
     (Can_Id   => 16#10#,
      Can_Dlc  => 1,
      Uu_Pad   => 16#FF#,
      Uu_Res0  => 16#FF#,
      Uu_Res1  => 16#FF#,
      Data     => (1 => 16#AA#,
		   others => 16#FF#));
   Frame_3  : constant Sockets.Can_Frame.Can_Frame := 
     (Can_Id   => 16#10#,
      Can_Dlc  => 4,
      Uu_Pad   => 16#FF#,
      Uu_Res0  => 16#FF#,
      Uu_Res1  => 16#FF#,
      Data     => (1 => 16#DE#,
		   2 => 16#AD#,
		   3 => 16#BE#,
		   4 => 16#EF#,
		   others => 16#FF#));
begin
   Bcm.Create (If_Name);
   Bcm.Send_Periodic (Frame_1, 0.5);
   Bcm.Send_Periodic (Frame_2, 1.0);
   Bcm.Send_Periodic (Frame_3, 1.5);
   
   Ada.Text_Io.Put_Line ("Press any key to stop");
   Ada.Text_Io.Get (Unused_C);
end Bcm_Cyclic_Writer;
