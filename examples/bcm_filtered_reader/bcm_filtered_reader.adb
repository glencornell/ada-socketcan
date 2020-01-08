with Ada.Text_Io;
with Sockets.Can.Broadcast_Manager;
with Sockets.Can_Frame;
with Create_Can_Frame;
with Print_Can_Frame;

procedure Bcm_Filtered_Reader is
   If_Name  : constant String := "vcan0";
   Unused_C : Character;
   Bcm      : Sockets.Can.Broadcast_Manager.Broadcast_Manager_Type;
   
   task type T is
      entry Start;
      entry Stop;
   end T;
   task body T is
      Terminated : Boolean := False;
      Frame      : Sockets.Can_Frame.Can_Frame;
   begin
      accept Start;
      while not Terminated loop
	 Bcm.Receive_Can_Frame (Frame);
	 Print_Can_Frame (Frame);
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
   Bcm.Add_Receive_Filter (Item => Create_Can_Frame(Can_Id => 16#20#, Data => (1 => 16#FF#)),
			   Interval => 1.0);
   Bcm.Add_Receive_Filter (Item => Create_Can_Frame(Can_Id => 16#30#, Data => (1 => 16#FF#)),
			   Interval => 1.0);
   
   Ada.Text_Io.Put_Line ("Press any key to stop");
   Updater.Start;
   
   Ada.Text_Io.Get (Unused_C);
   Updater.Stop;
end Bcm_Filtered_Reader;
