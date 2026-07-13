module pipelined_processor_FPU (
    // Para UVM e Síntese
    input we,
    input [31:0] WA,
    input [31:0] din,
    output RegWriteW,
    output RegWriteFW,
    output [4:0] RdW,
    output [31:0] ResultW,
    output [31:0] WriteDataM,
    output [31:0] ALUResultM,
    output [31:0] InstrDC,
    output MemWriteM,

    input clk, //
    input reset //
);

wire Zero;
wire Negative;
wire FPUAinSelD;
wire FPUAinSelE;
wire RegWriteD;
wire RegWriteFD;
wire RegWriteE;
wire RegWriteFE;
wire RegWriteM;
wire RegWriteFM;
//wire RegWriteW; virou output para UVM
//wire RegWriteFW; virou output para UVM
wire JumpD;
wire JumpE;
wire JumpRD;
wire JumpRE;
wire ALUSrcD;
wire ALUSrcE;
wire MemWriteD;
wire MemWriteE;
//wire MemWriteM; virou output para UVM
wire BranchD;
wire BranchE;
wire PCSrcE;
wire lwStall;
wire FlushD;
wire FlushE;
wire MemSrc;
wire MemSrcE;
wire ResultSel;
wire Upper;
wire isCompressed;
wire isCompressedD;
wire [1:0] ResultSrcD;
wire [1:0] ResultSrcE;
wire [1:0] ResultSrcM;
wire [1:0] ResultSrcW;
wire [1:0] ForwardAE;
wire [1:0] ForwardBE;
wire [2:0] ImmSrcD;
wire [2:0] funct3D;
wire [2:0] funct3E;
wire [2:0] funct3M;
wire [3:0] ALUControlD;
wire [3:0] ALUControlE;
wire [4:0] selFPUD;
wire [4:0] selFPUE;
wire [4:0] RdD;
wire [4:0] RdE;
wire [4:0] RdM;
//wire [4:0] RdW; virou output para UVM
wire [4:0] Rs1D;
wire [4:0] Rs2D;
wire [4:0] Rs1E;
wire [4:0] Rs2E;
wire [31:0] InstrF;
wire [31:0] InstrD;
//wire [31:0] InstrDC; virou output para UVM
wire [31:0] PCPlus4D;
wire [31:0] PCPlus4E;
wire [31:0] PCPlus4F;
wire [31:0] PCPlus4M;
wire [31:0] PCPlus4W;
//wire [31:0] PCtargetE;
wire [31:0] PCD;
wire [31:0] PCE;
wire [31:0] PCF;
wire [31:0] RD1D;
wire [31:0] RD2D;
wire [31:0] RDF1D;
wire [31:0] RDF2D;
wire [31:0] RD1E;
wire [31:0] RD2E;
wire [31:0] RDF1E;
wire [31:0] RDF2E;
wire [31:0] UpperResult;
wire [31:0] ImmExtD;
wire [31:0] ImmExtE;
//wire [31:0] ResultW; virou output para UVM
wire [31:0] WriteDataXE;
wire [31:0] WriteDataFE;
wire [31:0] WriteDataE;
//wire [31:0] WriteDataM; virou output para UVM
wire [31:0] Result;
//wire [31:0] ALUResultM; virou output para UVM
wire [31:0] ALUResultW;
wire [31:0] RD;
wire [31:0] FA_SIGNAL;
wire [31:0] ReadDataW;
wire [31:0] FUA;
wire [31:0] FUB;
wire [31:0] FUFA;
wire [31:0] FUFB;

Control_Unit C (
    .op(InstrDC[6:0]),
    .funct3(InstrDC[14:12]),
    .funct7b5(InstrDC[30]),
    .funct5(InstrDC[31:27]),
    .rm(InstrDC[14:12]),
    .ResultSrc(ResultSrcD),
    .JumpR(JumpRD),
    .ALUSrc(ALUSrcD),
    .RegWrite(RegWriteD),
    .RegWriteF(RegWriteFD),
    .MemSrc(MemSrc),
    .Jump(JumpD),
    .ImmSrc(ImmSrcD),
    .Upper(Upper),
	.ALUControl(ALUControlD),
    .MemWrite(MemWriteD),
    .selFPU(selFPUD),
    .ResultSel(ResultSel),
    .FPUAinSel(FPUAinSelD),
    .Branch(BranchD)
);

Fetch F (
    .clk(clk),
    .reset(reset),
    .PCSrc(PCSrcE),
    .EN(lwStall),
    .Imm(ImmExtE),
    .Result(Result),
    .isCompressedA(isCompressed),
    .PCE(PCE),
    .PCF(PCF),
    .InstrF(InstrF),
    .PCPlus4F(PCPlus4F),
    .JumpR(JumpRE),

    .we(we),
    .WA(WA),
    .din(din)
);

F_D_flipflop FD_REG (
    .clk(clk),
    .reset(reset),
    .PCPlus4F(PCPlus4F),
    .PCF(PCF),
    .isCompressed(isCompressed),
    .isCompressedD(isCompressedD),
    .EN(lwStall),
    .CLR(FlushD),
    .InstrF(InstrF),
    .InstrD(InstrD),
    .PCPlus4D(PCPlus4D),
    .PCD(PCD)
);

Decode D (
    .clk(clk),
    .WE3(RegWriteW),
    .WE3F(RegWriteFW),
    .ImmSrc(ImmSrcD),
    .RdW(RdW),
    .InstrF(InstrF),
    .InstrD(InstrD),
    .InstrDC(InstrDC),
    .PCD1(PCD[1]),
    .isCompressed(isCompressedD),
    .ResultW(ResultW),
    .RdD(RdD),
    .funct3(funct3D),
    .ImmExtD(ImmExtD),
    .RD1D(RD1D),
    .RD2D(RD2D),
    .Rs1D(Rs1D),
    .Rs2D(Rs2D),
    .RDF1D(RDF1D),
    .RDF2D(RDF2D)
);

mux_2x1 MUX_UPPER (
    .inA(RD1D),
    .inB(32'b0),
    .sel(Upper),
    .out(UpperResult)
);

D_E_flipflop DE_REG (
    .clk(clk),
    .reset(reset),
    .RegWriteD(RegWriteD),
    .MemWriteD(MemWriteD),
    .JumpD(JumpD),
    .JumpRD(JumpRD),
    .JumpRE(JumpRE),
    .MemSrc(MemSrc),
    .funct3D(funct3D),
    .selFPUD(selFPUD),
    .MemSrcE(MemSrcE),
    .BranchD(BranchD),
    .ALUSrcD(ALUSrcD),
    .ResultSrcD(ResultSrcD),
    .ALUControlD(ALUControlD),
    .RdD(RdD),
    .PCD(PCD),
    .PCPlus4D(PCPlus4D),
    .RD1D(UpperResult),
    .RD2D(RD2D),
    .RDF1D(RDF1D),
    .RDF2D(RDF2D),
    .RDF1E(RDF1E),
    .RDF2E(RDF2E),
    .ImmExtD(ImmExtD),
    .RegWriteE(RegWriteE),
    .MemWriteE(MemWriteE),
    .JumpE(JumpE),
    .BranchE(BranchE),
    .selFPUE(selFPUE),
    .ALUSrcE(ALUSrcE),
    .funct3E(funct3E),
    .ResultSrcE(ResultSrcE),
    .ALUControlE(ALUControlE),
    .RdE(RdE),
    .PCE(PCE),
    .PCPlus4E(PCPlus4E),
    .RD1E(RD1E),
    .RD2E(RD2E),
    .CLR(FlushE),
    .ImmExtE(ImmExtE),
    .RegWriteFD(RegWriteFD),
    .RegWriteFE(RegWriteFE),
    .FPUAinSelD(FPUAinSelD),
    .FPUAinSelE(FPUAinSelE),
    .Rs1D(Rs1D),
    .Rs1E(Rs1E),
    .Rs2D(Rs2D),
    .Rs2E(Rs2E)
);

Hazard_unit H (
    .RegWriteW(RegWriteW),
    .RegWriteM(RegWriteM),
    .RegWriteFW(RegWriteFW),
    .RegWriteFM(RegWriteFM),
    .RdM(RdM),
    .RdW(RdW),
    .RdE(RdE),
    .Rs1D(Rs1D),
    .Rs2D(Rs2D),
    .Rs1E(Rs1E),
    .Rs2E(Rs2E),
    .PCSrcE(PCSrcE),
    .FlushD(FlushD),
    .FlushE(FlushE),
    .ResultSrcE(ResultSrcE[0]),
    .ForwardAE(ForwardAE),
    .lwStall(lwStall),
    .ForwardBE(ForwardBE)
);

mux_3x1 ForwardingA(
    .inA(RD1E),
    .inB(ResultW),
    .inC(ALUResultM),
    .sel(ForwardAE),
    .out(FUA)
);

mux_3x1 ForwardingB(
    .inA(RD2E),
    .inB(ResultW),
    .inC(ALUResultM),
    .sel(ForwardBE),
    .out(FUB)
);

mux_2x1 FPU_Imm_MUX (
    .inA(RDF1E),
    .inB(RD1E),
    .sel(FPUAinSelE),
    .out(FA_SIGNAL)
);

mux_3x1 ForwardingFA(
    .inA(FA_SIGNAL),
    .inB(ResultW),
    .inC(ALUResultM),
    .sel(ForwardAE),
    .out(FUFA)
);

mux_3x1 ForwardingFB(
    .inA(RDF2E),
    .inB(ResultW),
    .inC(ALUResultM),
    .sel(ForwardBE),
    .out(FUFB)
);

Execute E (
    .ALUSrc(ALUSrcE),
    .MemSrc(MemSrcE),
    .ALUControl(ALUControlE),
    .selFPU(selFPUE),
    .RD1E(FUA),
    .RD2E(FUB),
    .RDF1E(FUFA),
    .RDF2E(FUFB),
    .ImmExtE(ImmExtE),
    //.PCE(PCE),
    .Zero(Zero),
    .Negative(Negative),
    .WriteDataXE(WriteDataXE),
    .WriteDataFE(WriteDataFE),
    .Result(Result)
    //.PCTargetE(PCtargetE)
);

Brancher B (
    .Zero(Zero),
    .funct3E(funct3E),
    .JumpE(JumpE),
    .Negative(Negative),
    .BranchE(BranchE),
    .PCSrcE(PCSrcE)
);

mux_2x1 Mem_mux(
    .inA(WriteDataXE),
    .inB(WriteDataFE),
    .sel(ResultSel),
    .out(WriteDataE)
);

E_M_flipflop EM_REG (
    .clk(clk),
    .reset(reset),
    .RegWriteE(RegWriteE),
    .RegWriteFE(RegWriteFE),
    .MemWriteE(MemWriteE),
    .ResultSrcE(ResultSrcE),
    .funct3E(funct3E),
    .RdE(RdE),
    .PCPlus4E(PCPlus4E),
    .WriteDataE(WriteDataE),
    .Result(Result),
    .RegWriteM(RegWriteM),
    .RegWriteFM(RegWriteFM),
    .MemWriteM(MemWriteM),
    .ResultSrcM(ResultSrcM),
    .RdM(RdM),
    .funct3M(funct3M),
    .ALUResultM(ALUResultM),
    .WriteDataM(WriteDataM),
    .PCPlus4M(PCPlus4M)
);

Memory M (
    .clk(clk),
    .WE(MemWriteM),
    .funct3M(funct3M),
    .ALUResultM(ALUResultM),
    .WriteDataM(WriteDataM),
    .RD(RD)
);

M_W_flipflop MW_REG(
    .clk(clk),
    .reset(reset),
    .RegWriteM(RegWriteM),
    .RegWriteFM(RegWriteFM),
    .ResultSrcM(ResultSrcM),
    .RdM(RdM),
    .ALUResultM(ALUResultM),
    .PCPlus4M(PCPlus4M),
    .RD(RD),
    .RegWriteW(RegWriteW),
    .RegWriteFW(RegWriteFW),
    .ResultSrcW(ResultSrcW),
    .RdW(RdW),
    .ALUResultW(ALUResultW),
    .PCPlus4W(PCPlus4W),
    .ReadDataW(ReadDataW)
);

Writeback W (
    .ResultSrc(ResultSrcW),
    .ALUResultW(ALUResultW),
    .PCPlus4W(PCPlus4W),
    .ReadDataW(ReadDataW),
    .ResultW(ResultW)
);

endmodule