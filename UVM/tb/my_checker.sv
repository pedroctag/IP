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

property ALU_EX_FLAG;
    @(posedge clk) disable iff(reset)
    !(flag_zero && flag_negativo);
endproperty
assert_ex_flag : assert property (ALU_EX_FLAG)
    else `uvm_error("SVA_MUTUAL_EXC", "[ERRO] Flags Zero e Negative ativas simultaneamente");


property BRANCH_EX_WE;
        @(posedge clk) disable iff(reset)
        branch_taken |-> weChecker;
endproperty
assert_ex_branch : assert property (BRANCH_EX_WE)
    else `uvm_error("SVA_ILLEGAL_STATE", "[ERRO] WE ativo durante um branch tomado");


property EX_JUMP_BRANCH;
    @(posedge clk) disable iff(reset)
    !(jump_signal && branch_signal);
endproperty
assert_ex_jump_branch : assert property (EX_JUMP_BRANCH)
    else `uvm_error("SVA_MUTUAL_EXC", "[ERRO] Sinais de jump e branch ativas simultaneamente");


endmodule