-- Copyright (C) 2012 Robert Dunn 
-- 2 input multiplexer

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

entity mux2 is
generic( width : natural := 32 );
port(
	i0,i1 : in std_logic_vector (width-1 downto 0);
	sel : in std_logic;
	o : out std_logic_vector (width-1 downto 0)
	);
end entity mux2;

architecture bh of mux2 is
begin
	process(sel,i0,i1)
	begin
		if(sel='0') then
		o <= i0;
		elsif(sel='1') then
		o <= i1;
		end if;
	end process;
end architecture bh;