function Create_Can_Frame (Can_Id : Sockets.Can_Frame.Can_Id_Type;
			   Data : Sockets.Can_Frame.Unconstrained_Can_Frame_Data_Array) return Sockets.Can_Frame.Can_Frame is
   Rval : Sockets.Can_Frame.Can_Frame :=
     (Can_Id   => Can_Id,
      Can_Dlc  => Data'Length,
      Uu_Pad   => 16#FF#,
      Uu_Res0  => 16#FF#,
      Uu_Res1  => 16#FF#,
      Data     => (others => 16#FF#));
   Dst : Sockets.Can_Frame.Can_Dlc_Type := Rval.Data'First;
begin
   for Src in Data'Range loop
      Rval.Data (Dst) := Data (Src);
      Dst := Sockets.Can_Frame.Can_Dlc_Type'Succ(Dst);
   end loop;
   return Rval;
end Create_Can_Frame;
