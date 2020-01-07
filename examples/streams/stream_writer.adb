with Sockets.Can;
with Sockets.Can_Frame;

procedure Stream_Writer is
   Socket       : Sockets.Can.Socket_Type;
   Frame        : Sockets.Can_Frame.Can_Frame;
   Can_Stream   : aliased Sockets.Can.Can_Stream;
begin
   Socket := Sockets.Can.Open("vcan0");
   Sockets.Can.Create_Stream (Can_Stream, Socket);
   
   frame.can_id  := 16#123#;
   frame.can_dlc := 2;
   frame.Data(1) := 16#11#;
   frame.Data(2) := 16#22#;
   
   Sockets.Can_Frame.Can_Frame'Write(Can_Stream'Access, Frame);
end Stream_Writer;
