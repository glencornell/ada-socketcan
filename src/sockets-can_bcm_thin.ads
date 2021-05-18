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

with Interfaces.C;
with Sockets.Can_Frame;

package Sockets.Can_Bcm_Thin is
   
   pragma Pure;
   
   type Timeval is record
      Tv_Sec  : aliased Interfaces.C.Long;
      Tv_Usec : aliased Interfaces.C.Long;
   end record;

   type Opcode_Type is
     (TX_SETUP,    -- create (cyclic) transmission task
      TX_DELETE,   -- remove (cyclic) transmission task
      TX_READ,     -- read properties of (cyclic) transmission task
      TX_SEND,     -- send one CAN frame
      RX_SETUP,    -- create RX content filter subscription
      RX_DELETE,   -- remove RX content filter subscription
      RX_READ,     -- read properties of RX content filter subscription
      TX_STATUS,   -- reply to TX_READ request
      TX_EXPIRED,  -- notification on performed transmissions (count=0)
      RX_STATUS,   -- reply to RX_READ request
      RX_TIMEOUT,  -- cyclic message is absent
      RX_CHANGED); -- updated CAN frame (detected content change)
   
   type Flag_Type is mod 2 ** 32;
   for Flag_Type'Size use 32;
   pragma Convention (C, Flag_Type);
      
   --  Possible values (logically OR'ed):
   SETTIMER           : constant Flag_Type := 16#00000001#;
   STARTTIMER         : constant Flag_Type := 16#00000002#;
   TX_COUNTEVT        : constant Flag_Type := 16#00000004#;
   TX_ANNOUNCE        : constant Flag_Type := 16#00000008#;
   TX_CP_CAN_ID       : constant Flag_Type := 16#00000010#;
   RX_FILTER_ID       : constant Flag_Type := 16#00000020#;
   RX_CHECK_DLC       : constant Flag_Type := 16#00000040#;
   RX_NO_AUTOTIMER    : constant Flag_Type := 16#00000080#;
   RX_ANNOUNCE_RESUME : constant Flag_Type := 16#00000100#;
   TX_RESET_MULTI_IDX : constant Flag_Type := 16#00000200#;
   RX_RTR_FRAME       : constant Flag_Type := 16#00000400#;
   CAN_FD_FRAME       : constant Flag_Type := 16#00000800#;
   
   type Frame_Count_Type is range 0..256;
   for Frame_Count_Type'Size use 32;
   pragma Convention (C, Frame_Count_Type);
   
   --  msg_head - head of messages to/from the broadcast manager. Note
   --  that this is not exactly the type as seen in linux/can/bcm.h.
   --  You must append the message array (with nframes elements) to
   --  this header before passing the structure to the kernel.
   type Bcm_Msg_Head is record
      Opcode  : aliased Opcode_Type;                   -- Opcode
      Flags   : aliased Flag_Type;                     -- Special flags, see below.
      Count   : aliased Frame_Count_Type;              -- number of frames to send before changing interval.
      Ival1   : aliased Timeval;                       -- interval for the first "count" frames.
      Ival2   : aliased Timeval;                       -- interval for the following frames.
      Can_Id  : aliased Sockets.Can_Frame.Can_Id_Type; -- CAN ID of frames to be sent or received.
      Nframes : aliased Frame_Count_Type;              -- Number of frames to be sent or received.
   end record;
   
   type Frame_Array_Type is array 
     (Frame_Count_Type range <>) of 
     aliased Sockets.Can_Frame.Can_Frame;
   
private
   
   pragma Convention (C_Pass_By_Copy, Timeval);
   pragma Convention (C, Opcode_Type);
   pragma Convention (C, Frame_Array_Type);
   pragma Convention (C_Pass_By_Copy, Bcm_Msg_Head);
   
   for Opcode_Type use
     (TX_SETUP   =>  1,
      TX_DELETE  =>  2,
      TX_READ    =>  3,
      TX_SEND    =>  4,
      RX_SETUP   =>  5,
      RX_DELETE  =>  6,
      RX_READ    =>  7,
      TX_STATUS  =>  8,
      TX_EXPIRED =>  9,
      RX_STATUS  => 10,
      RX_TIMEOUT => 11,
      RX_CHANGED => 12);
   
end Sockets.Can_Bcm_Thin;
