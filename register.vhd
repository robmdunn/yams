-- Copyright (C) 2012 Robert Dunn 
-- register

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
entity reg is 
generic (width : natural := 32);
port(
		D : in std_logic_vector(width-1 downto 0);
		Q, Qbar : out std_logic_vector(width-1 downto 0);
		clk,en,reset : in std_logic --reset active low
	);
end entity reg;

architecture beh of reg is
begin
	process(clk,reset)
	begin
	  if(reset='0') then
	  Q <= std_logic_vector( to_unsigned( 0, width));
	  else if (clk'event and clk='1' and en='1') then
		    Q <= D;
		    Qbar <= not D;
		  end if;
		end if;
	end process;
end architecture;