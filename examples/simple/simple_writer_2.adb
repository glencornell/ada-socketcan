with Sockets.Can;
with Sockets.Can_Frame;

procedure Simple_Writer_2 is
   Socket       : Sockets.Can.Socket_Type;
   Address      : Sockets.Can.Sock_Addr_Type;
   Frame        : Sockets.Can_Frame.Can_Frame;
begin
   Sockets.Can.Create_Socket(Socket);
   Address.If_Index := Sockets.Can.If_Name_To_Index("vcan0");
   Sockets.Can.Bind_Socket(Socket, Address);
   
   frame.can_id  := 16#123#;
   frame.can_dlc := 2;
   frame.Data(1) := 16#11#;
   frame.Data(2) := 16#22#;
   
   Sockets.Can.Send_Socket(Socket, Frame);
end Simple_Writer_2;
