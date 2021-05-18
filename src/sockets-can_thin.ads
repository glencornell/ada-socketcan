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
with GNAT.OS_Lib;

package Sockets.Can_Thin is
   
   pragma Preelaborate;
   
   use type Interfaces.C.Size_T;
     
   -- kernel socket address structure redefined here for CAN
   subtype data_array is Interfaces.C.char_array (0 .. 125);
   type kernel_sockaddr_storage is record
      ss_family : aliased Interfaces.C.unsigned_short;  --  address family
      data      : aliased data_array;                   --  implementation-specific field
   end record;
   
   -- transport protocol class address information (e.g. ISOTP)
   type Can_Addr_Type is record
      rx_id : aliased Can_Frame.Can_Id_Type;
      tx_id : aliased Can_Frame.Can_Id_Type;
   end record;
   
   -- the sockaddr structure for CAN sockets
   type sockaddr_can is record
      can_family  : aliased Interfaces.C.Unsigned_Short; -- address family number AF_CAN.
      can_ifindex : aliased Interfaces.C.Unsigned;       -- CAN network interface index.
      can_addr    : aliased Can_Addr_Type;               -- protocol specific address information
   end record;
   
   -- From /usr/include/net/if.h:
   IFNAMSIZ : constant := 16;
   subtype Ifr_Name_Array is Interfaces.C.char_array (0 .. IFNAMSIZ - 1);
   --  struct ifreq is much more complicated than presented below.  It
   --  is a collection of unions used for various protocols.  Since we
   --  are limiting use of this structure to CANbus interfaces, we
   --  have the liberty to declutter the unions and limit the
   --  representation of the structure to just the CAN-specfic data
   --  items.  Also, we will be only using the structure for finding
   --  the interface by name.  Use this at your own risk!
   type Ifreq is record
      Ifr_Name  : Ifr_Name_Array;        -- Interface name, e.g. "can0"
      Ifr_Index : Interfaces.C.Unsigned; -- Interface index
      Unused    : Interfaces.C.Char_Array (1 .. 20);  -- NOT USED
   end record;
   
   -- Use the POSIX.1 if_nametoindex() call to access the interface index:
   -- NOTE: OS limits ifname to IFNAMSIZ
   function If_Nametoindex (Ifname : Interfaces.C.Char_Array) return Interfaces.C.Unsigned;
   
   function Socket_Errno return Integer renames GNAT.OS_Lib.Errno;
   --  Returns last socket error number

   function Socket_Error_Message (Errno : Integer) return String;
   --  Returns the error message string for the error number Errno. If Errno is
   --  not known, returns "Unknown system error".
   
private
   
   pragma Convention (C_Pass_By_Copy, Kernel_Sockaddr_Storage);
   pragma Convention (C_Pass_By_Copy, Can_Addr_Type);
   pragma Convention (C_Pass_By_Copy, Sockaddr_Can);
   pragma Convention (C_Pass_By_Copy, Ifreq);
   
   for Ifreq'Size use 320;
   for Ifreq use record
      Ifr_Name  at  0 range 0 .. 127;
      Ifr_Index at 16 range 0 ..  31;
      Unused    at 20 range 0 .. 159;
   end record;
   
   pragma Import (C, If_Nametoindex, "if_nametoindex");

end Sockets.Can_Thin;
