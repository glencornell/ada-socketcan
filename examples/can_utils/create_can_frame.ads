with Sockets.Can_Frame;

function Create_Can_Frame (Can_Id : Sockets.Can_Frame.Can_Id_Type;
			   Data : Sockets.Can_Frame.Unconstrained_Can_Frame_Data_Array) return Sockets.Can_Frame.Can_Frame;
--  Create a CAN frame from the given ID and data.
