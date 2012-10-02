-- Copyright (C) 2012 Robert Dunn 
-- MIPS opcodes and function codes

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

package mips_ops is

-- rop: ooooooss sssttttt dddddaaa aaffffff
-- iop: ooooooss sssttttt iiiiiiii iiiiiiii
-- jop: ooooooii iiiiiiii iiiiiiii iiiiiiii

--Opcodes

  subtype opcode is std_logic_vector(5 downto 0);
  
  constant op_R : opcode     := "000000";  --Register operation controlled by fn code
  constant op_addi : opcode  := "001000";  --add immediate
  constant op_addiu : opcode := "001001";  --add immediate no overflow
  constant op_slti : opcode  := "001010";  --Set less than immediate (if rs < imm then rt <:= 1 else rt <:= 0)
  constant op_sltiu : opcode := "001011";  --Set less than immediate unsigned (if rs < imm then rt <:= 1 else rt <:= 0)
  constant op_andi : opcode  := "001100";  --AND immediate
  constant op_ori : opcode   := "001101";	 --OR immediate
  constant op_xori : opcode  := "001110";  --XOR immediate

  constant op_lb  : opcode := "100000";  --load byte (sign extend)
  constant op_lh  : opcode := "100001";  --load halfword (sign extend)
  constant op_lw  : opcode := "100011";  --load word
  constant op_lbu : opcode := "100100"; --load byte unsigned
  constant op_lhu : opcode := "100101"; --load halfword unsigned 

--  constant op_lui : opcode := "001111"; --load upper immediate (load lower halfword of imm into upper halfword of rd)
--  constant op_lhi : opcode := "011001"; --HH ($t) = i
--  constant op_llo : opcode := "011000"; --LH ($t) = i
  
  constant op_sw : opcode := "101011";  --store word
  constant op_sh : opcode := "101001";  --store halfword
  constant op_sb : opcode := "101000";  --store byte
  
  constant op_beq : opcode  := "000100";  --branch equal
  constant op_bne : opcode  := "000101";  --branch not equal
--  constant op_blez : opcode := "000110";  --branch less equal zero
--  constant op_bgtz : opcode := "000111";  --branch greater than zero
      
  constant op_j   : opcode := "000010";  --jump
  constant op_jal : opcode := "000011";  --jump and link, $31 = pc
  
--  constant op_trap : opcode := "011010";  --insert science dog here

  
--Function Codes  (op="000000")
  
  constant fn_add  : opcode := "100000"; --add 
  constant fn_addu : opcode := "100001"; --add no overflow
  constant fn_sub  : opcode := "100010"; --sub
  constant fn_subu : opcode := "100011"; --sub no overflow
  
--  constant fn_mult  : opcode := "011000";  --multiply, hi<:=upper word, lo<:=lower word
--  constant fn_multu : opcode := "011001";  --multiply unsigned, hi<:=upper word, lo<:=lower word  
--  constant fn_div   : opcode := "011010";   --divide, lo<:=rs/rt, hi<:=rs%rt
--  constant fn_divu  : opcode := "011011";  --divide unsigned, lo<:=rs/rt, hi<:=rs%rt
  
--  constant fn_mfhi : opcode := "010000";  --move from hi
--  constant fn_mflo : opcode := "010010";  --move from lo
--  constant fn_mthi : opcode := "010001";  --move to hi
--  constant fn_mtlo : opcode := "010011";  --move to lo
  
  constant fn_and : opcode := "100100";  --AND
  constant fn_or  : opcode := "100101";   --OR
  constant fn_xor : opcode := "100110";  --XOR
  constant fn_nor : opcode := "100111";  --NOR
  
  constant fn_slt  : opcode := "101010"; --set less than
  constant fn_sltu : opcode := "101001"; --set less than unsigned
  
  constant fn_sll  : opcode := "000000"; --shift left logical (use aaaaa field)
  constant fn_srl  : opcode := "000010"; --shift right logical (use aaaaa field)
  constant fn_sra  : opcode := "000011"; --shift right arithmetic (sign bit shifted in) (use aaaaa field)
  
  constant fn_sllv : opcode := "000100"; --shift left logical variable
  constant fn_srlv : opcode := "000110"; --shift right logical variable
  constant fn_srav : opcode := "000111"; --shift right arithmetic variable (sign bit shifted in)  
  
  constant fn_jr   : opcode := "001000";  --jump register
  constant fn_jalr : opcode := "001001";  --jump register and link
  
end mips_ops;
  
   