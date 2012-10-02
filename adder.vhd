-- Copyright (C) 2012 Robert Dunn 
-- Adder component

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
use ieee.std_logic_signed.all;


entity adder is 
generic (width : natural := 32); 
port(   A, B : in std_logic_vector (width-1 downto 0);
        Cin : in std_logic;
        Y : out std_logic_vector (width-1 downto 0);
        Cout, Overflow : out std_logic 
    );
end entity;

architecture behav of adder is
    signal temp : std_logic_vector (width downto 0);
begin
  temp <= ("0"&A) + ("0"&B) + Cin;
  Y <= temp(width-1 downto 0);
  Cout <= temp(width);
  Overflow <= temp(width) xor A(width-1) xor B(width-1) xor temp(width-1);
end behav;