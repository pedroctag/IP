module pipelined_processor (
    input clk, //
    input reset //
);

wire Zero;
wire RegWriteD;
wire RegWriteE;
wire RegWriteM;
wire RegWriteW;
wire JumpD;
wire JumpE;
wire ALUSrcD;
wire ALUSrcE;
wire MemWriteD;
wire MemWriteE;
wire MemWriteM;
wire BranchD;
wire BranchE;
wire PCSrcE;
wire lwStall;
wire FlushD;
wire FlushE;
wire [1:0] ResultSrcD;
wire [1:0] ResultSrcE;
wire [1:0] ResultSrcM;
wire [1:0] ResultSrcW;
wire [1:0] ImmSrcD;
wire [1:0] ForwardAE;
wire [1:0] ForwardBE;
wire [3:0] ALUControlD;
wire [3:0] ALUControlE;
wire [4:0] RdD;
wire [4:0] RdE;
wire [4:0] RdM;
wire [4:0] RdW;
wire [4:0] Rs1D;
wire [4:0] Rs2D;
wire [4:0] Rs1E;
wire [4:0] Rs2E;
wire [31:0] InstrF;
wire [31:0] InstrD;
wire [31:0] PCPlus4D;
wire [31:0] PCPlus4E;
wire [31:0] PCPlus4F;
wire [31:0] PCPlus4M;
wire [31:0] PCPlus4W;
wire [31:0] PCtargetE;
wire [31:0] PCtargetD;
wire [31:0] PCD;
wire [31:0] PCE;
wire [31:0] PCF;
wire [31:0] RD1D;
wire [31:0] RD2D;
wire [31:0] RD1E;
wire [31:0] RD2E;
wire [31:0] ImmExtD;
wire [31:0] ImmExtE;
wire [31:0] ResultW;
wire [31:0] WriteDataE;
wire [31:0] WriteDataM;
wire [31:0] Result;
wire [31:0] ALUResultM;
wire [31:0] ALUResultW;
wire [31:0] RD;
wire [31:0] ReadDataW;
wire [31:0] FUA;
wire [31:0] FUB;

Control_Unit C (
    .op(InstrD[6:0]),
    .funct3(InstrD[14:12]),
    .funct7b5(InstrD[30]),
    .ResultSrc(ResultSrcD),
    .ALUSrc(ALUSrcD),
    .RegWrite(RegWriteD),
    .Jump(JumpD),
    .ImmSrc(ImmSrcD),
	.ALUControl(ALUControlD),
    .MemWrite(MemWriteD), 
    .Branch(BranchD)
);

Fetch F (
    .clk(clk),
    .reset(reset),
    .PCSrc(PCSrcE),
    .PCTargetE(PCtargetE),
    .PCPlus4F(PCPlus4F),
    .PCF(PCF),
    .EN(lwStall),
    .InstrF(InstrF)
);

F_D_flipflop FD_REG (
    .clk(clk),
    .reset(reset),
    .PCPlus4F(PCPlus4F),
    .PCF(PCF),
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
    .ImmSrc(ImmSrcD),
    .RdW(RdW),
    .ResultW(ResultW),
    .InstrD(InstrD),
    .RdD(RdD),
    .ImmExtD(ImmExtD),
    .RD1D(RD1D),
    .RD2D(RD2D),
    .Rs1D(Rs1D),
    .Rs2D(Rs2D)
);

D_E_flipflop DE_REG (
    .clk(clk),
    .reset(reset),
    .RegWriteD(RegWriteD),
    .MemWriteD(MemWriteD),
    .JumpD(JumpD),
    .BranchD(BranchD),
    .ALUSrcD(ALUSrcD),
    .ResultSrcD(ResultSrcD),
    .ALUControlD(ALUControlD),
    .RdD(RdD),
    .PCD(PCD),
    .PCPlus4D(PCPlus4D),
    .RD1D(RD1D),
    .RD2D(RD2D),
    .ImmExtD(ImmExtD),
    .RegWriteE(RegWriteE),
    .MemWriteE(MemWriteE),
    .JumpE(JumpE),
    .BranchE(BranchE),
    .ALUSrcE(ALUSrcE),
    .ResultSrcE(ResultSrcE),
    .ALUControlE(ALUControlE),
    .RdE(RdE),
    .PCE(PCE),
    .PCPlus4E(PCPlus4E),
    .RD1E(RD1E),
    .RD2E(RD2E),
    .CLR(FlushE),
    .ImmExtE(ImmExtE),
    .Rs1D(Rs1D),
    .Rs1E(Rs1E),
    .Rs2D(Rs2D),
    .Rs2E(Rs2E)
);

Hazard_unit H (
    .RegWriteW(RegWriteW),
    .RegWriteM(RegWriteM),
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

Execute E (
    .ALUSrc(ALUSrcE),
    .ALUControl(ALUControlE),
    .RD1E(FUA),
    .RD2E(FUB),
    .ImmExtE(ImmExtE),
    .PCE(PCE),
    .Zero(Zero),
    .WriteDataE(WriteDataE),
    .Result(Result),
    .PCTargetE(PCtargetE)
);

assign PCSrcE = (Zero & BranchE) | JumpE;

E_M_flipflop EM_REG (
    .clk(clk),
    .reset(reset),
    .RegWriteE(RegWriteE),
    .MemWriteE(MemWriteE),
    .ResultSrcE(ResultSrcE),
    .RdE(RdE),
    .PCPlus4E(PCPlus4E),
    .WriteDataE(WriteDataE),
    .Result(Result),
    .RegWriteM(RegWriteM),
    .MemWriteM(MemWriteM),
    .ResultSrcM(ResultSrcM),
    .RdM(RdM),
    .ALUResultM(ALUResultM),
    .WriteDataM(WriteDataM),
    .PCPlus4M(PCPlus4M)
);

Memory M (
    .clk(clk),
    .WE(MemWriteM),
    .ALUResultM(ALUResultM),
    .WriteDataM(WriteDataM),
    .RD(RD)
);

M_W_flipflop MW_REG(
    .clk(clk),
    .reset(reset),
    .RegWriteM(RegWriteM),
    .ResultSrcM(ResultSrcM),
    .RdM(RdM),
    .ALUResultM(ALUResultM),
    .PCPlus4M(PCPlus4M),
    .RD(RD),
    .RegWriteW(RegWriteW),
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