import uvm_pkg::*;
`include "uvm_macros.svh"

import my_pkg::*;

module top_tb;

reg clk;

// Instancia a Interface UVM passiva/ativa
dut_if inf (
    .clk(clk)
);

// Instancia o módulo topo do RISC-V (DUT)
pipelined_processor_FPU dut (
    .clk (clk),
    .reset (inf.reset),
    // Sinais de Carga da Memória (UVM Driver -> Hardware)
    .we (inf.we),
    .WA (inf.Instr_WA),
    .din (inf.Instr_din),      
    .InstrDC (inf.Monitor_Instr), // Para monitorar a instrução atual no estágio D
    // Sinais de Monitoramento (Hardware -> UVM Monitor)
    .RegWriteW (inf.Monitor_RegWriteW),
    .RegWriteFW (inf.Monitor_RegWriteFW),
    .RdW (inf.Monitor_RdW),
    .ResultW (inf.Monitor_ResultW),
    .WriteDataM (inf.WriteDataM),
    .MemWriteM (inf.MemWriteM),
    .ALUResultM (inf.Monitor_ALUResultM)
);

bind pipelined_processor_FPU my_checker checker_inst (
    .clk (clk),
    .reset (reset),
    .flag_negativo (Negative),
    .flag_zero (Zero),
    .branch_taken (PCSrcE),
    .branch_signal (BranchE),
    .jump_signal (JumpE),
    .weChecker (we),
    .lwStall(lwStall),
    .FlushD(FlushD),
    .FlushE(FlushE),
    .FlushPF(FlushPF),
    .PFBStall(PFBStall),
    .ForwardAE(ForwardAE),
    .ForwardBE(ForwardBE),
    .Instr (InstrDC)
);

assign inf.Monitor_flag_zero     = dut.Zero;
assign inf.Monitor_flag_negativo = dut.Negative;
assign inf.Monitor_branch_taken  = dut.PCSrcE;
assign inf.Monitor_weChecker     = inf.we;

assign inf.Monitor_lwStall = dut.lwStall;
assign inf.Monitor_FlushD = dut.FlushD;
assign inf.Monitor_FlushE = dut.FlushE;
//assign inf.Monitor_FlushPF = dut.FlushPF;
//assign inf.Monitor_PFBStall = dut.PFBStall;
assign inf.Monitor_ForwardAE = dut.ForwardAE;
assign inf.Monitor_ForwardBE = dut.ForwardBE;

assign inf.Monitor_upper = dut.Upper;
assign inf.Monitor_Imm = dut.ImmSrcD;
assign inf.Monitor_FPUAinSel = dut.FPUAinSelD;
assign inf.Monitor_ALUSrc = dut.ALUSrcD;
assign inf.Monitor_MemSrc = dut.MemSrc;
assign inf.Monitor_ALUControl = dut.ALUControlD;
assign inf.Monitor_FPUControl = {dut.InstrDC[31:27], dut.InstrDC[14:12]};
assign inf.Monitor_ResultSel = dut.ResultSel;
assign inf.Monitor_ResultSrc = dut.ResultSrcD;
assign inf.Monitor_MemWrite = dut.MemWriteD;
assign inf.Monitor_RegWrite = dut.RegWriteD;
assign inf.Monitor_RegWriteF = dut.RegWriteFD;
assign inf.Monitor_Branch = dut.BranchD;
assign inf.Monitor_Jump = dut.JumpD;

assign inf.Monitor_isCompressed = dut.D.DCP.isCompressed;
assign inf.Monitor_isCompressedA = dut.F.CompressedFlag.isCompressedA;
assign inf.Monitor_isCompressedD = dut.D.DCP.isCompressed;
assign inf.Monitor_PC1 = dut.D.IA.PC1;

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

// Bloco UVM: Configura a interface virtual e dispara o Teste
initial begin
    // Disponibiliza a interface física para o banco de dados de configuração do UVM
    uvm_config_db#(virtual dut_if)::set(null, "*", "vif", inf);
        
    // Dispara o teste UVM (chama o build_phase, run_phase, etc.)
    run_test("my_test");
end

// trecho para debug
always @(posedge clk) begin
  if (dut.RegWriteW) begin
    //$display("Instrucao: 0x%h", inf.Monitor_Instr);
    //$display("DUMP TOPO TRACE | Valor no RTL: 0x%h | ULA = %h | Instr: %h | AD: %h | BD: %h | Instr e HW: %h %h", dut.W.ResultW, dut.E.Result, dut.D.InstrDC, dut.D.RD1D, dut.D.RD2D, dut.D.InstrD, dut.D.HalfWordD);
    //$display("DUMP DCP | iC: %h | Instruction: %h", dut.D.DCP.isCompressed, dut.D.DCP.Instruction);
    //$display("DUMP IA | PC: %h | PC1: %h | Instr: %h | ManipulatedInstruction: %h", dut.F.PCF, dut.F.IA.PC1, dut.F.IA.Instr, dut.F.IA.ManipulatedInstruction);
    //$display("DUMP PFB | iC: %h | Instr: %h | next: %h | EN: %h | Flush: %h\n\n", dut.F.PFB.isCompressed, dut.F.PFB.InstructionA, dut.F.PFB.InstructionB, dut.F.PFB.EN, dut.F.PFB.Flush);
    //$display("DUMP MEM | instrucao da memoria %h", dut.F.IM.RD[dut.F.PCF]);
end
end

endmodule