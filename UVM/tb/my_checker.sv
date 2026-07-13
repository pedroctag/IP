module my_checker (
    input clk,
    input reset,
    input flag_zero,
    input flag_negativo,
    input branch_taken,
    input branch_signal,
    input jump_signal,
    input weChecker, 
    input lwStall,
    input FlushD,
    input FlushE,
    input FlushPF,
    input PFBStall,
    input [1:0] ForwardAE,
    input [1:0] ForwardBE,
    input [31:0] Instr
);

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  // ---------------------------------------------------------
  // 1. Mutuamente Exclusivo: Zero e Negativo
  // Um número não pode ser exatamente zero e negativo ao mesmo tempo.
  // ---------------------------------------------------------
  property ALU_EX_FLAG;
      @(posedge clk) disable iff(reset)
      not (flag_zero && flag_negativo);
  endproperty

  assert_ex_flag : assert property (ALU_EX_FLAG)
      else `uvm_error("SVA_MUTUAL_EXC", "[ERRO] Flags Zero e Negative ativas simultaneamente");

  // ---------------------------------------------------------
  // 2. Implicação: Branch Taken -> Sem Escrita (WE = 0)
  // CORREÇÃO APLICADA AQUI: Adicionado a negação "!" no weChecker
  // ---------------------------------------------------------
  property BRANCH_EX_WE;
      @(posedge clk) disable iff(reset)
      branch_taken |-> !weChecker;
  endproperty

  assert_ex_branch : assert property (BRANCH_EX_WE)
      else `uvm_error("SVA_ILLEGAL_STATE", "[ERRO] WE ativo durante um branch tomado");

  // ---------------------------------------------------------
  // 3. Mutuamente Exclusivo: Jump e Branch
  // Uma única instrução não pode ser decodificada como jump e branch simultaneamente.
  // ---------------------------------------------------------
  property EX_JUMP_BRANCH;
      @(posedge clk) disable iff(reset)
      not (jump_signal && branch_signal);
  endproperty

  assert_ex_jump_branch : assert property (EX_JUMP_BRANCH)
      else `uvm_error("SVA_MUTUAL_EXC", "[ERRO] Sinais de jump e branch ativas simultaneamente");

endmodule
