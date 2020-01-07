with Sockets.Can;
with Sockets.Can_Frame;
with Print_Can_Frame;

procedure Stream_Reader is
   Socket       : Sockets.Can.Socket_Type;
   Can_Stream   : aliased Sockets.Can.Can_Stream;
   Frame        : Sockets.Can_Frame.Can_Frame;
   If_Name      : constant String := "vcan0";
begin
   Socket := Sockets.Can.Open(If_Name);
   Sockets.Can.Create_Stream (Can_Stream, Socket);
   
   loop 
      Sockets.Can_Frame.Can_Frame'Read (Can_Stream'Access, Frame);
      Print_Can_Frame (Frame, If_Name);
   end loop;
end Stream_Reader;
