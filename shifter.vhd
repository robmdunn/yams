-- Copyright (C) 2012 Robert Dunn 
-- Shifter

-- This library is free software; you can redistribute it and/or
-- modify it under the terms of the GNU Lesser General Public
-- License as published by the Free Software Foundation; either
-- version 2.1 of the License, or (at your option) any later version.

-- This library is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
-- Lesser General Public License for more details.

-- You should have received a copy of the GNU Lesser General Public
-- License along with this library; if not, write to the Free Software
-- Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity shifter is
generic( width : natural := 32 );
port(
	op : in std_logic_vector(1 downto 0);
	v_op : in std_logic;
	imm : in std_logic_vector(4 downto 0);
	A,B : in std_logic_vector(width-1 downto 0);
	Y : out std_logic_vector(width-1 downto 0)
	);
end entity;

architecture beh of shifter is
  signal shift : integer;
begin
  shift <= to_integer(unsigned(A)) when v_op='1' else to_integer(unsigned(imm)); 
	process(op, imm, A)
	  begin
			case op is
				when "00" =>
					Y <= to_stdlogicvector(to_bitvector(B) sll shift);
				when "01" =>
					Y <= to_stdlogicvector(to_bitvector(B));
				when "10" =>
					Y <= to_stdlogicvector(to_bitvector(B) srl shift);
				when "11" =>
					Y <= to_stdlogicvector(to_bitvector(B) sra shift);
				when others =>
					Y <= to_stdlogicvector(to_bitvector(B));
		  end case;
	end process;
end architecture beh;