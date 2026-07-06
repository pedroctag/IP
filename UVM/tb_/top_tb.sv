import uvm_pkg::*;
`include "uvm_macros.svh"

import my_pkg::*;

module top_tb;

// 1. Sinais globais de Clock e Reset
reg clk;
reg rst_n; // ou 'reset' dependendo de como chamou no seu hardware
reg we;


// 2. Instancia a Interface UVM passiva/ativa
// Passamos o clock e o reset de hardware para dentro dela
dut_if inf (
    .clk(clk)
);

// 3. Instancia o SEU módulo topo do RISC-V (DUT)
// Conectamos os pinos do seu processador diretamente aos sinais da interface (inf.sinal)
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

// 4. Gerador de Clock (Período de 10 unidades de tempo)
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

// 5. Gerador de Reset Inicial
initial begin
    inf.we = 1;
    inf.reset = 1;
    #3500 inf.reset = 0;
    inf.we = 0;
end

// 6. Bloco UVM: Configura a interface virtual e dispara o Teste
initial begin
    // Disponibiliza a interface física para o banco de dados de configuração do UVM
    uvm_config_db#(virtual dut_if)::set(null, "*", "vif", inf);
        
    // Dispara o teste UVM (chama o build_phase, run_phase, etc.)
    run_test("my_test");
end

// trecho para debug
always @(posedge clk) begin
  if (dut.RegWriteW) begin 
    //$display("DUMP TOPO TRACE | Valor no RTL: 0x%h | ULA = %h | Instr: %h | AD: %h | BD: %h | Instr e HW: %h %h", dut.W.ResultW, dut.E.Result, dut.D.InstrDC, dut.D.RD1D, dut.D.RD2D, dut.D.InstrD, dut.D.HalfWordD);
    //$display("DUMP DCP | iC: %h | Instruction: %h", dut.D.DCP.isCompressed, dut.D.DCP.Instruction);
    //$display("DUMP IA | PC: %h | PC1: %h | Instr: %h | ManipulatedInstruction: %h", dut.F.PCF, dut.F.IA.PC1, dut.F.IA.Instr, dut.F.IA.ManipulatedInstruction);
    //$display("DUMP PFB | iC: %h | Instr: %h | next: %h | EN: %h | Flush: %h\n\n", dut.F.PFB.isCompressed, dut.F.PFB.InstructionA, dut.F.PFB.InstructionB, dut.F.PFB.EN, dut.F.PFB.Flush);
    //$display("DUMP MEM | instrucao da memoria %h", dut.F.IM.RD[dut.F.PCF]);
end
end

endmodule