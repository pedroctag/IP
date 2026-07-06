interface dut_if(input wire clk);
    // Para UVM e Síntese
    logic reset;
    logic we;
    logic [31:0] Monitor_Instr;
    logic [31:0] Instr_WA;
    logic [31:0] Instr_din;
    logic Monitor_RegWriteW;
    logic Monitor_RegWriteFW;
    logic [4:0] Monitor_RdW;
    logic [31:0] Monitor_ResultW;
    logic [31:0] WriteDataM;
    logic MemWriteM;
    logic [31:0] Monitor_ALUResultM;
    logic Monitor_flag_zero;
    logic Monitor_flag_negativo;
    logic Monitor_branch_taken;
    logic Monitor_weChecker;

    logic Monitor_upper;
    logic [2:0] Monitor_Imm;
    logic Monitor_FPUAinSel;
    logic Monitor_ALUSrc;
    logic Monitor_MemSrc;
    logic [3:0] Monitor_ALUControl;
    logic [7:0] Monitor_FPUControl;
    logic [1:0] Monitor_ResultSel;
    logic [1:0] Monitor_ResultSrc;
    logic Monitor_MemWrite;
    logic Monitor_RegWrite;
    logic Monitor_RegWriteF;
    logic Monitor_Branch;
    logic Monitor_Jump;

    logic Monitor_isCompressed;
    logic Monitor_isCompressedA;
    logic Monitor_isCompressedD;
    logic Monitor_PC1;

    logic Monitor_lwStall;
    logic Monitor_FlushD;
    logic Monitor_FlushE;
    //logic Monitor_FlushPF;
    //logic Monitor_PFBStall;
    logic [1:0] Monitor_ForwardAE;
    logic [1:0] Monitor_ForwardBE;
endinterface
