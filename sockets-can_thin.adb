with System.Os_Lib; use System.Os_Lib;

package body Sockets.Can_Thin is
   
   --------------------------
   -- Socket_Error_Message --
   --------------------------
   
   function Socket_Error_Message
     (Errno : Integer) return String
   is
   begin
      return Errno_Message (Errno, Default => "Unknown system error");
   end Socket_Error_Message;
   
end Sockets.Can_Thin;
