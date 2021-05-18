-- MIT License
--
-- Copyright (c) 2021 Glen Cornell <glen.m.cornell@gmail.com>
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.

with Ada.Text_Io;
with Sockets.Can.Broadcast_Manager;
with Sockets.Can_Frame;
with Interfaces;
with Create_Can_Frame;

procedure Bcm_Simple_Writer is
   If_Name  : constant String := "vcan0";
   Unused_C : Character;
   Bcm      : Sockets.Can.Broadcast_Manager.Broadcast_Manager_Type;
   Frame_1  : constant Sockets.Can_Frame.Can_Frame := 
     Create_Can_Frame (Can_Id   => 16#10#,
		       Data     => (16#11#, 16#22#, 16#33#));
   Frame_2  : Sockets.Can_Frame.Can_Frame := 
     Create_Can_Frame (Can_Id   => 16#20#,
		       Data     => (1 => 16#AA#));
   Frame_3  : constant Sockets.Can_Frame.Can_Frame := 
     Create_Can_Frame (Can_Id   => 16#30#,
		       Data     => (16#DE#, 16#AD#, 16#BE#, 16#EF#));
   
   task type T is
      entry Start;
      entry Stop;
   end T;
   task body T is
      use type Interfaces.Unsigned_8;
      I : Interfaces.Unsigned_8 := 255;
      Terminated : Boolean := False;
   begin
      accept Start;
      while not Terminated loop
	 I := I + 1;
	 Frame_2.Data(Frame_2.Data'First) := I;
	 Bcm.Send_Once (Frame_2);
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
   Bcm.Send_Periodic (Frame_1, 0.5);
   Bcm.Send_Once (Frame_2);
   Bcm.Send_Once (Frame_3);
   
   Updater.Start;
   
   Ada.Text_Io.Put_Line ("Press any key to stop");
   Ada.Text_Io.Get (Unused_C);
   Updater.Stop;
end Bcm_Simple_Writer;
