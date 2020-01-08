with Sockets.Can;
with Sockets.Can_Frame;
with Create_Can_Frame;

procedure Simple_Writer is
   Socket       : Sockets.Can.Socket_Type;
   Frame        : constant Sockets.Can_Frame.Can_Frame :=
     Create_Can_Frame (Can_Id => 16#123#,
		       Data   => (16#11#, 16#22#, 16#33#));
begin
   Socket := Sockets.Can.Open("vcan0");
   Sockets.Can.Send_Socket(Socket, Frame);
end Simple_Writer;
