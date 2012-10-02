-- Copyright (C) 2012 Robert Dunn 
-- register file

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

entity reg_file is
generic ( width : natural := 32 );
port ( 
		rs, rt, rd : in std_logic_vector (4 downto 0);
		rd_in : in std_logic_vector (width-1 downto 0);
		clk : in std_logic;
		wr_en : in std_logic;
		rs_out, rt_out : out std_logic_vector (width-1 downto 0)
	);
end entity reg_file;

architecture reg_file of reg_file is
  type registers is array (natural range <>) of std_logic_vector (width-1 downto 0);
	signal reg: registers(0 to 31) := ((others=> (others=>'0')));
	signal rs_int, rt_int, rd_int : integer range 0 to 31;
begin
  rs_int <= to_integer(unsigned(rs));
  rt_int <= to_integer(unsigned(rt));
  rd_int <= to_integer(unsigned(rd));
  rs_out <= reg(rs_int);
  rt_out <= reg(rt_int);
	
	
	process(clk)
	begin
		if(clk='1' and wr_en='1' and rd_int/=0)	then
		  reg(rd_int) <= rd_in;
		end if;
	end process;
end architecture reg_file;