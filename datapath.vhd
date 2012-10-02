-- Copyright (C) 2012 Robert Dunn 
-- MIPS classic 5 stage RISC pipeline w/ delayed branching.
-- Author: Robert Dunn
-- Modified 3/5/2012

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



--known issues:
--trap, syscall, break NYI
--sh and sb ops will store an entire word

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.mips_comps.all;
use work.mips_ops.all;

entity datapath is 
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
end entity datapath;

architecture datapath of datapath is

  signal if_pc_out, if_pc_next, if_br_dest, if_pc_plus4, if_4: std_logic_vector (width-1 downto 0);
  signal if_pc_en : std_logic;
  signal ifid_ir_next :std_logic_vector(31 downto 0);
  signal ifid_en : std_logic;
  
  signal id_ir : std_logic_vector (31 downto 0);
  signal id_op, id_fn : opcode;
  signal id_rs, id_rt, id_rd : std_logic_vector (4 downto 0);
  signal id_A,id_B,id_imm,id_imm4,id_pc : std_logic_vector (width-1 downto 0);
  signal id_r_eq, id_j_op, id_branch, id_stall: std_logic;
  
  signal idex_A_next,idex_B_next : std_logic_vector (width-1 downto 0);
  signal idex_ir_next : std_logic_vector(31 downto 0);
  signal idex_en : std_logic;
  
  signal ex_A,ex_B,ex_imm,ex_alu_B,ex_alu_out,ex_shifter_out,ex_pc : std_logic_vector(width-1 downto 0);
  signal ex_ir : std_logic_vector(31 downto 0);
  signal ex_op, ex_fn : opcode;
  signal ex_alu_op : std_logic_vector(2 downto 0);
  signal ex_stall, ex_cmp_u, ex_lt, ex_shift_op, ex_shift_v, ex_slt_op : std_logic;
  signal ex_shifter_op : std_logic_vector (1 downto 0);
  signal ex_shift, ex_rt,ex_rd : std_logic_vector (4 downto 0);
  
  signal exmem_alu_out, exmem_b_next : std_logic_vector(width-1 downto 0);
  signal exmem_ir_next : std_logic_vector(31 downto 0);
  signal exmem_en : std_logic;

  signal mem_ir : std_logic_vector(31 downto 0);
  signal mem_alu_out, mem_B,mem_pc : std_logic_vector(width-1 downto 0);
  signal mem_op : opcode;
  signal mem_stall : std_logic;
  signal mem_rt,mem_rd : std_logic_vector (4 downto 0);
  
  signal memwb_alu_out, memwb_lmd : std_logic_vector(width-1 downto 0);
  signal memwb_ir_next : std_logic_vector(31 downto 0);
  
  signal wb_wr_en : std_logic;
  signal wb_alu_out, wb_lmd, wb_rdata, wb_pc : std_logic_vector(width-1 downto 0);
  signal wb_ir : std_logic_vector(31 downto 0);
  signal wb_op, wb_fn : opcode;
  signal wb_rt, wb_rd, wb_rdest : std_logic_vector (4 downto 0);

begin
--IF stage
  
  if_pc_en <= not(i_stall or id_stall or ex_stall or mem_stall);
  
  if_PC: reg generic map (width => width) port map(D=>if_pc_next, Q=>if_pc_out, clk=>clk, en=>if_pc_en, reset=>reset); -- program counter    
  if_pc_incr: adder generic map (width => width) port map(A=>if_4, B=>if_pc_out, Cin=>'0', Y=>if_pc_plus4); --program counter increment
  i_addr <= if_pc_out; --send PC to memory
  
  if_pc_next <= idex_a_next when (id_branch='1' and (id_op=op_r and (id_fn=fn_jr or id_fn=fn_jalr))) else if_br_dest when (id_branch='1') else if_pc_plus4; --next pc
  
  if_4 <= std_logic_vector( to_unsigned( 4, width)); -- constant 4 input to pc_next
        
--IF/ID registers
  
  ifid_pc: reg generic map (width => 32) port map(D=>if_pc_out, Q=>id_pc, clk=>clk, en=>ifid_en, reset=>reset);
  ifid_IR: reg generic map (width => 32) port map(D=>ifid_ir_next, Q=>id_ir, clk=>clk, en=>ifid_en, reset=>reset);  
    
  ifid_ir_next <= i_in when(i_stall /= '1') else std_logic_vector( to_unsigned( 0, width)); --instruction fetch, insert bubble on i_stall 
  
  ifid_en <= not(id_stall or ex_stall or mem_stall); --stall from later in pipeline
  
--ID stage 

  id_regfile: reg_file generic map (width => width) 
  port map ( rs=>id_rs, rt=>id_rt, rd=>wb_rdest, rd_in=>wb_rdata, clk=>clk, wr_en=>wb_wr_en, rs_out=>id_A, rt_out=>id_B);
    
  id_sign_ext: signext generic map (width=>width) port map(imm=>id_ir(25 downto 0),j_op=>id_j_op,Y=>id_imm ); --sign extender
  
  id_branch_dest_adder: adder generic map (width=>width) port map(A=>id_imm4, B=>if_pc_out, Cin=>'0', Y=> if_br_dest); --branch/jump dest = 4*imm+pc
    
  id_op <= id_ir(31 downto 26);
  id_rs <= id_ir(25 downto 21);
  id_rt <= id_ir(20 downto 16);
  id_rd <= id_ir(15 downto 11);
  id_fn <= id_ir(5 downto 0);
  
  id_j_op <= '1' when ( (id_op=op_j) or (id_op=op_jal) ) else '0' ; --j_op used to pick immediate length

  id_r_eq <= '1' when (idex_a_next = idex_b_next) else '0';  --compare a to b for branching
  
  id_branch <= '1' when ((id_op=op_beq and id_r_eq='1') or (id_op=op_bne and id_r_eq='0') or (id_j_op='1') or (id_op=op_r and (id_fn=fn_jr or id_fn=fn_jalr))) else '0'; --branch on br or j

  id_imm4(width-1 downto 0) <= id_imm (width-3 downto 0)&"00";  --multiply immediate by 4 (imm sll 2)

  --interlock when ex_op is load and next op uses its result  
  id_stall <= '1' when ((ex_op=op_lb or ex_op=op_lh or ex_op=op_lw or ex_op=op_lbu or ex_op=op_lhu) 
                        and ((ex_rt=id_rs and id_rs/="00000") or (ex_rt=id_rt and id_op=op_R and id_rt/="00000"))) else '0'; 
  
--ID/EX registers 
  
  idex_pc: reg generic map (width => 32) port map(D=>id_pc, Q=>ex_pc, clk=>clk, en=>idex_en, reset=>reset);
  idex_A: reg generic map (width => width) port map(D=>idex_A_next, Q=>ex_A, clk=>clk, en=>idex_en, reset=>reset);
  idex_B: reg generic map (width => width) port map(D=>idex_B_next, Q=>ex_B, clk=>clk, en=>idex_en, reset=>reset);
  idex_IR: reg generic map (width => 32) port map(D=>idex_ir_next, Q=>ex_ir, clk=>clk, en=>idex_en, reset=>reset);
  idex_imm: reg generic map (width => width) port map(D=>id_imm, Q=>ex_imm, clk=>clk, en=>idex_en, reset=>reset);
    
  idex_ir_next <= id_ir when (id_stall/='1') else std_logic_vector( to_unsigned( 0, width)); --insert bubble on id_stall
  
  idex_A_next <= exmem_alu_out when (ex_rd=id_rs and ex_op=op_R) or   --forwarding/bypassing happens here
                        (ex_rt=id_rs and (ex_op=op_addi or ex_op=op_addiu or ex_op=op_slti or 
                        ex_op=op_sltiu or ex_op=op_andi or ex_op=op_ori or ex_op=op_xori)) else
                  memwb_alu_out when (mem_rd=id_rs and mem_op=op_R) or
                        (mem_rt=id_rs and (mem_op=op_addi or mem_op=op_addiu or mem_op=op_slti or 
                        mem_op=op_sltiu or mem_op=op_andi or mem_op=op_ori or mem_op=op_xori)) else
                  memwb_lmd when (mem_rt=id_rs and
                        (mem_op=op_lb or mem_op=op_lh or mem_op=op_lw or mem_op=op_lbu or mem_op=op_lhu))
                  else id_A;
            
  idex_B_next <= exmem_alu_out when (ex_rd=id_rt and ex_op=op_R) or   --forwarding/bypassing happens here
                        (ex_rt=id_rt and (ex_op=op_addi or ex_op=op_addiu or ex_op=op_slti or 
                        ex_op=op_sltiu or ex_op=op_andi or ex_op=op_ori or ex_op=op_xori)) else 
                  memwb_alu_out when (mem_rd=id_rt and mem_op=op_R) or
                        (mem_rt=id_rt and (mem_op=op_addi or mem_op=op_addiu or mem_op=op_slti or 
                        mem_op=op_sltiu or mem_op=op_andi or mem_op=op_ori or mem_op=op_xori)) else                  
                  memwb_lmd when (mem_rt=id_rt and
                        (mem_op=op_lb or mem_op=op_lh or mem_op=op_lw or mem_op=op_lbu or mem_op=op_lhu))
                  else id_B;
  
  idex_en <= not(ex_stall or mem_stall); --stall from later in pipeline
  
--EX stage
  
  ex_alu: alu generic map (width=> width) port map (A=>ex_A, B=>ex_alu_b, Cin=>'0', op=>ex_alu_op, Y=>ex_alu_out );
  ex_shifter: shifter generic map (width => width) port map (A=>ex_A, B=>ex_B, Y=>ex_shifter_out, v_op=>ex_shift_v, op=>ex_shifter_op, imm=>ex_shift);
  ex_compare: comparator generic map (width => width) port map(A=>ex_A, B=>ex_B, u=>ex_cmp_u, lt=>ex_lt);
    
  ex_op <= ex_ir(31 downto 26); 
  ex_rt <= ex_ir(20 downto 16);
  ex_rd <= ex_ir(15 downto 11);
  ex_shift <= ex_ir(10 downto 6);  --shifter immediate field 
  ex_fn <= ex_ir(5 downto 0);
  
  ex_shifter_op <= ex_ir(1 downto 0); --shifter op is last 2 bits of fn
  
  ex_slt_op <= '1' when ex_op=op_sltiu or ex_op=op_slti or (ex_op=op_R and (ex_fn=fn_sltu or ex_fn=fn_slt)) else '0'; --slt operation
  
  ex_shift_op <= '1' when (ex_op=op_R and (ex_fn=fn_sll or ex_fn=fn_srl or ex_fn=fn_sra or ex_shift_v='1')) else '0'; --shifter operation
  ex_shift_v <= '1' when (ex_fn=fn_sllv or ex_fn=fn_srlv or ex_fn=fn_srav) else '0';  --variable shifter operation
  
  ex_cmp_u <= '1' when (ex_op=op_sltiu or (ex_op=op_R and ex_fn=fn_sltu)) else '0'; --unsigned compare op
  
  ex_alu_B <= ex_B when (ex_op=op_R) else ex_imm; --mux alu b for R op and I op
  
  ex_stall <= '0'; --no execution stalls yet.
  
  process(ex_op,ex_fn) -- alu op control
  begin
    case ex_op is
    when op_R => 
      case ex_fn is
      when fn_add =>
        ex_alu_op <= "100";
      when fn_addu =>
        ex_alu_op <= "100";
      when fn_sub =>
        ex_alu_op <= "101";
      when fn_subu =>
        ex_alu_op <= "101";
      when fn_and =>
        ex_alu_op <= "001";
      when fn_or =>
        ex_alu_op <= "010";
      when fn_xor =>
        ex_alu_op <= "011";
      when fn_nor =>
        ex_alu_op <= "000";
      when others =>
        ex_alu_op <= "110"; --pass A
      end case;
    when op_addi =>
      ex_alu_op <= "100";
    when op_addiu =>
      ex_alu_op <= "100";
    when op_andi =>
      ex_alu_op <= "001";
    when op_ori =>
      ex_alu_op <= "010";
    when op_xori =>
      ex_alu_op <= "011";
    when op_lw =>
      ex_alu_op <= "100";
    when op_lh =>
      ex_alu_op <= "100";
    when op_lhu =>
      ex_alu_op <= "100";
    when op_lb =>
      ex_alu_op <= "100";
    when op_lbu=>
      ex_alu_op <= "100";
    when op_sw =>
      ex_alu_op <= "100";
    when op_sh =>
      ex_alu_op <= "100";
    when op_sb =>
      ex_alu_op <= "100";
    when others =>
      ex_alu_op <= "110"; --pass A
    end case;
  end process;
  
--EX/MEM registers

  exmem_pc: reg generic map (width => 32) port map(D=>ex_pc, Q=>mem_pc, clk=>clk, en=>exmem_en, reset=>reset);
  exmem_alu_output: reg generic map (width => width) port map(D=>exmem_alu_out, Q=>mem_alu_out, clk=>clk, en=>exmem_en, reset=>reset);
  exmem_B: reg generic map (width => width) port map(D=>exmem_b_next, Q=>mem_B, clk=>clk, en=>exmem_en, reset=>reset);
  exmem_ir: reg generic map (width => width) port map(D=>exmem_ir_next, Q=>mem_ir, clk=>clk, en=>exmem_en, reset=>reset);
  
  exmem_ir_next <= ex_ir when (ex_stall/='1') else std_logic_vector( to_unsigned( 0, width)); --insert bubble on ex_stall
  
  exmem_alu_out <= ex_shifter_out when ex_shift_op='1' else std_logic_vector( to_unsigned( 0, width-1))&ex_lt when ex_slt_op='1' else ex_alu_out;
                   
  exmem_b_next <= ex_b;
  
  exmem_en <= not(mem_stall); --stall from later in pipeline
  
--MEM stage

  mem_op <= mem_ir(31 downto 26);
  mem_rt <= mem_ir(20 downto 16);
  mem_rd <= mem_ir(15 downto 11);
  
  mem_w <= '1' when (mem_op=op_sw or mem_op=op_sh or mem_op=op_sb) else '0'; --write on store op
  mem_r <= '1' when (mem_op=op_lb or mem_op=op_lh or mem_op=op_lw or mem_op=op_lbu or mem_op=op_lhu) else '0'; --read on load op
  
  d_out <= mem_b;
  d_addr <= mem_alu_out;
  
  --only stall in mem when d_stall='1' and load/store op is in mem_ir:
  mem_stall <= '1' when (d_stall='1' and (mem_op=op_sw or mem_op=op_sh or mem_op=op_sb or mem_op=op_lb 
                                    or mem_op=op_lh or mem_op=op_lw or mem_op=op_lbu or mem_op=op_lhu)) else '0'; 
    
--MEM/WB registers

  memwb_pc: reg generic map (width => 32) port map(D=>mem_pc, Q=>wb_pc, clk=>clk, en=>'1', reset=>reset);
  memwb_alu_ouput: reg generic map (width => width) port map(D=>memwb_alu_out,Q=>wb_alu_out,clk=>clk, en=>'1', reset=>reset);
  memwb_lmd_reg : reg generic map (width => width) port map(D=>memwb_lmd,Q=>wb_lmd,clk=>clk, en=>'1', reset=>reset);
  memwb_ir: reg generic map (width => width) port map(D=>memwb_ir_next,Q=>wb_ir,clk=>clk, en=>'1', reset=>reset);

  memwb_ir_next <= mem_ir when (mem_stall/='1') else std_logic_vector( to_unsigned( 0, width)); --insert bubble on mem_stall
  
  process(d_in,mem_op) --mask/sign extend load ops
    begin
    case mem_op is
    when op_lw =>
      memwb_lmd <= d_in;
    when op_lh =>
      memwb_lmd <= std_logic_vector(resize(signed(d_in(15 downto 0)), memwb_lmd'length));
    when op_lb =>
      memwb_lmd <= std_logic_vector(resize(signed(d_in(7 downto 0)), memwb_lmd'length));
    when op_lhu =>
      memwb_lmd <= std_logic_vector(resize(unsigned(d_in(15 downto 0)), memwb_lmd'length));
    when op_lbu =>
      memwb_lmd <= std_logic_vector(resize(unsigned(d_in(7 downto 0)), memwb_lmd'length));
    when others =>
      memwb_lmd <= d_in;
    end case;
  end process;
  
  memwb_alu_out <= mem_alu_out;
    
--WB Stage

  wb_op <= wb_ir(31 downto 26);
  
  wb_rt <= wb_ir(20 downto 16);
  wb_rd <= wb_ir(15 downto 11);
  wb_fn <= wb_ir(5 downto 0);
  
  wb_rdata <= mem_pc when ((wb_op=op_R and wb_fn=fn_jalr) or wb_op=op_jal) else 
              wb_lmd when (wb_op=op_lb or wb_op=op_lh or wb_op=op_lw or wb_op=op_lbu or wb_op=op_lhu) 
              else wb_alu_out;
  wb_rdest <= "11111" when ((wb_op=op_R and wb_fn=fn_jalr) or wb_op=op_jal) else 
              wb_rd when (wb_op=op_R) 
              else wb_rt; --write to r31 on jal else rd on R-op else rt
  wb_wr_en <= '1' when (wb_op=op_R or wb_op=op_addi or wb_op=op_addiu or wb_op=op_slti or 
                        wb_op=op_sltiu or wb_op=op_andi or wb_op=op_ori or wb_op=op_xori or 
                        wb_op=op_lb or wb_op=op_lh or wb_op=op_lw or wb_op=op_lbu or wb_op=op_lhu or wb_op=op_jal) else '0';
  
end architecture;