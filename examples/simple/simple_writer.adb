with Sockets.Can;
with Sockets.Can_Frame;

procedure Simple_Writer is
   Socket       : Sockets.Can.Socket_Type;
   Frame        : Sockets.Can_Frame.Can_Frame;
begin
   Socket := Sockets.Can.Open("vcan0");
   
   frame.can_id  := 16#123#;
   frame.can_dlc := 2;
   frame.Data(1) := 16#11#;
   frame.Data(2) := 16#22#;
   
   Sockets.Can.Send_Socket(Socket, Frame);
end Simple_Writer;
