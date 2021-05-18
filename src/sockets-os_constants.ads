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

-- To be merged with gnat.sockets.os_constants...
-- from /usr/inlude/linux/can.h
-- from /usr/inlude/linux/can/raw.h
-- from /usr/inlude/bits/socket_type.h

package Sockets.Os_Constants is
   
   pragma Pure;
   
   -- special address description flags for the CAN_ID
   CAN_EFF_FLAG : constant := 16#80000000#; -- EFF/SFF is set in the MSB
   CAN_RTR_FLAG : constant := 16#40000000#; -- remote transmission request
   CAN_ERR_FLAG : constant := 16#20000000#; -- error message frame

   -- valid bits in CAN ID for frame formats
   CAN_SFF_MASK : constant := 16#000007FF#; -- standard frame format (SFF)
   CAN_EFF_MASK : constant := 16#1FFFFFFF#; -- extended frame format (EFF)
   CAN_ERR_MASK : constant := 16#1FFFFFFF#; -- omit EFF, RTR, ERR flags
   
   CAN_INV_FILTER     : constant := 16#20000000#; -- to be set in can_filter.can_id
   CAN_RAW_FILTER_MAX : constant := 512;          -- maximum number of can_filter set via setsockopt()
   
   -----------------------
   -- protocol families --
   -----------------------
   
   SOCK_RAW    : constant := 3; -- Raw protocol interface.
   
   -- particular protocols of the protocol family PF_CAN
   CAN_RAW     : constant := 1; -- RAW sockets
   CAN_BCM     : constant := 2; -- Broadcast Manager
   CAN_TP16    : constant := 3; -- VAG Transport Protocol v1.6
   CAN_TP20    : constant := 4; -- VAG Transport Protocol v2.0
   CAN_MCNET   : constant := 5; -- Bosch MCNet
   CAN_ISOTP   : constant := 6; -- ISO 15765-2 Transport Protocol
   CAN_NPROTO  : constant := 7;

   -- Protocol families.
   PF_CAN        : constant := 29; --  Controller Area Network.

   -- Address families.
   AF_CAN        : constant := PF_CAN; 
   
   --------------------
   -- Socket options --
   --------------------
   
   SOL_CAN_BASE          : constant := 100;
   SOL_CAN_RAW           : constant := SOL_CAN_BASE + CAN_RAW;
   CAN_RAW_FILTER        : constant := 1; -- set 0 .. n can_filter(s)
   CAN_RAW_ERR_FILTER    : constant := 2; -- set filter for error frames
   CAN_RAW_LOOPBACK      : constant := 3; -- local loopback (default:on)
   CAN_RAW_RECV_OWN_MSGS : constant := 4; -- receive my own msgs (default:off)
   CAN_RAW_FD_FRAMES     : constant := 5; -- allow CAN FD frames (default:off)
   CAN_RAW_JOIN_FILTERS  : constant := 6; -- all filters must match to trigger
   
end Sockets.Os_Constants;
