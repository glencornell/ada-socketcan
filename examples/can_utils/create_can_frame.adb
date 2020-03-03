--  Copyright (C) 2020 Glen Cornell <glen.m.cornell@gmail.com>
--  
--  This program is free software: you can redistribute it and/or
--  modify it under the terms of the GNU General Public License as
--  published by the Free Software Foundation, either version 3 of the
--  License, or (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
--  General Public License for more details.
--
--  You should have received a copy of the GNU General Public License
--  along with this program.  If not, see
--  <http://www.gnu.org/licenses/>.

function Create_Can_Frame (Can_Id : Sockets.Can_Frame.Can_Id_Type;
			   Data : Sockets.Can_Frame.Unconstrained_Can_Frame_Data_Array) return Sockets.Can_Frame.Can_Frame is
   Rval : Sockets.Can_Frame.Can_Frame :=
     (Can_Id   => Can_Id,
      Can_Dlc  => Data'Length,
      Uu_Pad   => 16#FF#,
      Uu_Res0  => 16#FF#,
      Uu_Res1  => 16#FF#,
      Data     => (others => 16#FF#));
   Dst : Sockets.Can_Frame.Can_Dlc_Type := Rval.Data'First;
begin
   for Src in Data'Range loop
      Rval.Data (Dst) := Data (Src);
      Dst := Sockets.Can_Frame.Can_Dlc_Type'Succ(Dst);
   end loop;
   return Rval;
end Create_Can_Frame;
