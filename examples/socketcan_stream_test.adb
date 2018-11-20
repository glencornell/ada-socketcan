with Sockets.Can;
with Sockets.Can_Frame;

procedure Socketcan_Stream_Test is
   Socket       : Sockets.Can.Socket_Type;
   Address      : Sockets.Can.Sock_Addr_Type;
   Frame        : Sockets.Can_Frame.Can_Frame;
   Can_Stream   : aliased Sockets.Can.Can_Stream;
begin
   Sockets.Can.Create_Socket(Socket);
   Address.If_Index := Sockets.Can.If_Name_To_Index("vcan0");
   Sockets.Can.Bind_Socket(Socket, Address);
   Sockets.Can.Create_Stream (Can_Stream, Socket);
   
   frame.can_id  := 16#123#;
   frame.can_dlc := 2;
   frame.Data(1) := 16#11#;
   frame.Data(2) := 16#22#;
   
   Sockets.Can_Frame.Can_Frame'Write(Can_Stream'Access, Frame);
end Socketcan_Stream_Test;
