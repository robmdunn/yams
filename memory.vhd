-- Copyright (C) 2012 Robert Dunn 
-- Memory for testbench use.

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

entity memory is 
generic ( bytewidth : natural := 4;
		  size : natural := 4096 );
port ( 
		i_addr,d_addr : in std_logic_vector ((bytewidth*8)-1 downto 0);
		w,r,clk : in std_logic;
		i_out : out std_logic_vector (31 downto 0);
		d_in : in std_logic_vector ((bytewidth*8)-1 downto 0);
		d_out : out std_logic_vector ((bytewidth*8)-1 downto 0);
		i_stall, d_stall : out std_logic := '0'
		);
end entity;

architecture beh of memory is
type memory is array (0 to size) of std_logic_vector (7 downto 0);
signal m : memory := (

0=>"00100000",
1=>"00000011",
2=>"01010101",
3=>"01010101",

4=>"00100000",
5=>"00000110",
6=>X"DE",
7=>X"AD",

8=>"00100000",
9=>"00001000",
10=>X"BE",
11=>X"EF",

12=>"00100000",
13=>"00001010",
14=>"00000000",
15=>"00001000",

16=>"00100000",
17=>"00000001",
18=>"00000000",
19=>"00000000",

20=>"10001100",
21=>"00100010",
22=>"00000001",
23=>"11110100",

24=>"00000000",
25=>"01100010",
26=>"00100000",
27=>"00100000",

28=>"00000000",
29=>"01000100",
30=>"00101000",
31=>"00100110",

32=>"00000000",
33=>"10100110",
34=>"00111000",
35=>"00100010",

36=>"00000000",
37=>"11101000",
38=>"01001000",
39=>"00100101",

40=>"00100001",
41=>"01001010",
42=>"11111111",
43=>"11111111",

44=>"10101100",
45=>"00101001",
46=>"00000001",
47=>"11110100",

48=>"00010100",
49=>"00001010",
50=>"11111111",
51=>"11111000",

52=>"00100000",
53=>"00100001",
54=>"00000000",
55=>"00000100",

60=>"00001011",
61=>"11111111",
62=>"11111111",
63=>"11110000",

others=>"00000000");

begin
mem: process(clk)
	begin		  

	if (clk'event and clk='0') then
	
		instr_out: for n in 0 to 3 loop
			i_out(7+(8*(3-n)) downto 0+(8*(3-n))) <= m(n+to_integer(unsigned(i_addr)) mod size);
		end loop instr_out;
		
		if(w='0' and r='1') then
			data_out: for n in 0 to (bytewidth-1) loop
				d_out(7+(8*(bytewidth-1-n)) downto 0+(8*(bytewidth-1-n))) <= m(n+to_integer(unsigned(d_addr)) mod size);
			end loop data_out;
		end if;
		
		if(w='1') then
			data_in: for n in 0 to (bytewidth-1) loop
				m(n+to_integer(unsigned(d_addr)) mod size) <= d_in(7+(8*(bytewidth-1-n)) downto 0+(8*(bytewidth-1-n)));
			end loop data_in;	
		end if;
		
	end if;
end process;
			
end architecture beh;