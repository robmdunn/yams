-- Copyright (C) 2012 Robert Dunn 
-- Sign extender

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

entity signext is
generic( width : natural := 32 );
port( 
	imm : in std_logic_vector (25 downto 0);
	j_op : in std_logic;
	Y : out std_logic_vector (width-1 downto 0)
	);
end entity signext;

architecture beh of signext is
begin
	process(imm,j_op)
	begin
		if (j_op='0') then
			Y (15 downto 0) <= imm (15 downto 0);
			Y (Y'high downto 16) <= (others => imm(15));
		else if (j_op='1') then
			Y (25 downto 0) <= imm;
			Y (Y'high downto 26) <= (others => imm(25));
		end if;
		end if;
	end process;
end architecture beh;