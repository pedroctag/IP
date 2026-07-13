module Decode (
    input clk,
    input WE3,
    input WE3F,
    input isCompressed,
    input PCD1,
    input [2:0] ImmSrc,
    input [4:0] RdW,
    input [31:0] ResultW,
    input [31:0] InstrF,
    input [31:0] InstrD,
    output [2:0] funct3,
    output [4:0] RdD,
    output [4:0] Rs1D,
    output [4:0] Rs2D,
    output [31:0] ImmExtD,
    output [31:0] RD1D,
    output [31:0] RD2D,
    output [31:0] RDF1D,
    output [31:0] InstrDC,
    output [31:0] RDF2D
);

wire [15:0] HalfWordD;
wire [31:0] MInstr;

assign RdD = InstrDC[11:7];
assign Rs1D = InstrDC[19:15];
assign Rs2D = InstrDC[24:20];
assign funct3 = InstrDC[14:12];

Register_File RFX (
    .clk(clk),
    .RA1(InstrDC[19:15]),
    .RA2(InstrDC[24:20]),
    .WA3(RdW),
    .WD3(ResultW),
    .WE3(WE3),
    .RD1(RD1D),
    .RD2(RD2D)
);

Register_File RFF (
    .clk(clk),
    .RA1(InstrDC[19:15]),
    .RA2(InstrDC[24:20]),
    .WA3(RdW),
    .WD3(ResultW),
    .WE3(WE3F),
    .RD1(RDF1D),
    .RD2(RDF2D)
);

Extend Extend (
    .Instr(InstrDC[31:7]),
    .ImmSrc(ImmSrc),
    .ImmExt(ImmExtD)
);

InstructionAlign IA (
    .Instr(InstrD),
    .NextInstr(InstrF),
    .PC1(PCD1),
    .ManipulatedInstruction(MInstr),
    .HalfWord(HalfWordD)
);

Decompressor DCP (
    .isCompressed(isCompressed),
    .HalfWord(HalfWordD),
    .Instruction(MInstr),
    .InstrCOMPLETE(InstrDC)
);

endmodule