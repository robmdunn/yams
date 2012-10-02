-- Copyright (C) 2012 Robert Dunn 
-- Comparator, outputs greater than, less than, and eq signals for A and B input

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

entity comparator is 
generic (width : natural := 32);
port (
    A, B : in std_logic_vector (width-1 downto 0);
    u : in std_logic; --unsigned, active high.
    gt, lt, eq : out std_logic
  );
end entity comparator;

architecture beh of comparator is
begin

  gt <= '1' when (u='0' and signed(A) > signed(B)) or (u='1' and unsigned(A) > unsigned(B(15 downto 0))) else '0';
  eq <= '1' when (u='0' and signed(A) = signed(B)) or (u='1' and unsigned(A) = unsigned(B(15 downto 0))) else '0';
  lt <= '1' when (u='0' and signed(A) < signed(B)) or (u='1' and unsigned(A) < unsigned(B(15 downto 0))) else '0';
  
end architecture;