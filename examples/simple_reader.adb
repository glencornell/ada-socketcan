with Sockets.Can;
with Sockets.Can_Frame;
with Print_Can_Frame;

procedure Simple_Reader is
   Socket       : Sockets.Can.Socket_Type;
   Frame        : Sockets.Can_Frame.Can_Frame;
   If_Name      : constant String := "vcan0";
begin
   Socket := Sockets.Can.Open(If_Name);
   loop 
      Sockets.Can.Receive_Socket(Socket, Frame);
      Print_Can_Frame (Frame, If_Name);
   end loop;
end Simple_Reader;
