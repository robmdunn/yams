-- Copyright (C) 2012 Robert Dunn 
-- ALU for MIPS datapath 

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


entity alu is 
generic (width : natural := 32); 
port(   A, B : in std_logic_vector (width-1 downto 0);
        op : in std_logic_vector (2 downto 0);
        Cin : in std_logic;
        Y : out std_logic_vector (width-1 downto 0);
        Cout : out std_logic; 
		Overflow : out std_logic
    );
end entity alu;

architecture alu_behav of alu is
  component adder
    generic (width : natural := 32);
    port(   A, B : in std_logic_vector (width-1 downto 0);
            Cin : in std_logic;
            Y : out std_logic_vector (width-1 downto 0);
            cout, overflow : out std_logic 
    );
  end component;
	signal B_in, sum : std_logic_vector (width-1 downto 0);
	signal carry : std_logic;
begin
  adder_comp: adder generic map (width => width) port map(A, B_in, carry, sum, cout, overflow);
  process(A,B,op,Cin,carry,sum)
  begin
    case op is
      when "000" => -- nor 
		    carry <= '0';
        Y <= A nor B;
      when "001" => -- and
		    carry <= '0';
        Y <= A and B;
      when "010" => -- or
		    carry <= '0';
        Y <= A or B; 
      when "011" => -- xor
		    carry <= '0';
        Y <= A xor B;
      when "100" => -- add 
        carry <= '0';
        B_in <= B;
        Y <= sum;
      when "101" => -- sub
        carry <= '1';
        B_in <= not(B);
        Y <= sum;
      when "110" => -- no op a 
		    carry <= '0';
        Y <= A;
      when "111" => -- no op b
		    carry <= '0';
        Y <= B;
      when others =>
	      carry <= '0';
        Y <= std_logic_vector( to_unsigned( 0, width));       
    end case;
  end process;
end alu_behav;
  
