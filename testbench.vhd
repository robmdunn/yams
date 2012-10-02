-- Copyright (C) 2012 Robert Dunn 
-- Testbench for datapath.vhd

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

entity testbench is 
generic (width : natural := 32);
end entity testbench;

architecture testbench of testbench is
component datapath is 
generic ( width : natural := 32);
port (
		clk, reset : in std_logic; --reset active low
		i_addr, d_addr : out std_logic_vector (width-1 downto 0);
		mem_w, mem_r : out std_logic;
		i_in : in std_logic_vector (31 downto 0);
		d_in : in std_logic_vector (width-1 downto 0);
		d_out : out std_logic_vector (width-1 downto 0);		
		i_stall, d_stall : in std_logic
		);
end component datapath;

component memory is 
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
end component;

signal i_addr, d_addr,d_in,d_out :std_logic_vector(width-1 downto 0);
signal i_in : std_logic_vector (31 downto 0);
signal mem_w, mem_r, i_stall, d_stall : std_logic;
signal reset, clk : std_logic := '0';
begin
  datapath_uut: datapath generic map (width=>width) port map(clk, reset, i_addr, d_addr, mem_w, mem_r, i_in, d_in, d_out, i_stall, d_stall);
  mem: memory generic map(bytewidth=>(width/8)) port map(i_addr, d_addr, mem_w, mem_r, clk, i_in, d_out, d_in, i_stall, d_stall);

clk <= not clk after 50 ps;
reset <= '1' after 100 ps;

end architecture testbench;