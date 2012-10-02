-- Copyright (C) 2012 Robert Dunn 
-- component prototypes

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

package mips_comps is

component reg is 
generic (width : natural := 32);
port(
		D : in std_logic_vector(width-1 downto 0);
		Q, Qbar : out std_logic_vector(width-1 downto 0);
		clk,en,reset : in std_logic --reset active low
	);
end component reg;

component adder is 
generic (width : natural := 32); 
port(   A, B : in std_logic_vector (width-1 downto 0);
        Cin : in std_logic;
        Y : out std_logic_vector (width-1 downto 0);
        Cout, Overflow : out std_logic 
    );
end component adder;
  
component shifter is
generic( width : natural := 32 );
port(
	op : in std_logic_vector(1 downto 0);
	v_op : in std_logic;
	imm : in std_logic_vector(4 downto 0);
	A,B : in std_logic_vector(width-1 downto 0);
	Y : out std_logic_vector(width-1 downto 0)
	);
end component shifter;

component signext is
generic( width : natural := 32 );
port( 
	imm : in std_logic_vector (25 downto 0);
	j_op : in std_logic;
	Y : out std_logic_vector (width-1 downto 0)
	);
end component signext;

component alu is 
generic (width : natural := 32); 
port(   A, B : in std_logic_vector (width-1 downto 0);
        op : in std_logic_vector (2 downto 0);
        Cin : in std_logic;
        Y : out std_logic_vector (width-1 downto 0);
        Cout : out std_logic; 
		Overflow : out std_logic
    );
end component alu;

component reg_file is
generic ( width : natural := 32 );
port ( 
		rs, rt, rd : in std_logic_vector (4 downto 0);
		rd_in : in std_logic_vector (width-1 downto 0);
		clk : in std_logic;
		wr_en : in std_logic;
		rs_out, rt_out : out std_logic_vector (width-1 downto 0)
	);
end component reg_file;

component comparator is 
generic (width : natural := 32);
port (
    A, B : in std_logic_vector (width-1 downto 0);
    u : in std_logic;
    gt, lt, eq : out std_logic
  );
end component comparator;

end package;