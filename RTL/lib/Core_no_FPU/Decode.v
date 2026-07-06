module Decode (
    input clk,
    input WE3,
    input [1:0] ImmSrc,
    input [4:0] RdW,
    input [31:0] ResultW,
    input [31:0] InstrD,
    output [4:0] RdD,
    output [4:0] Rs1D,
    output [4:0] Rs2D,
    output [31:0] ImmExtD,
    output [31:0] RD1D,
    output [31:0] RD2D
);

assign RdD = InstrD[11:7];
assign Rs1D = InstrD[19:15];
assign Rs2D = InstrD[24:20];

Register_File RF (
    .clk(clk),
    .RA1(InstrD[19:15]),
    .RA2(InstrD[24:20]),
    .WA3(RdW),
    .WD3(ResultW),
    .WE3(WE3),
    .RD1(RD1D),
    .RD2(RD2D)
);

Extend Extend (
    .Instr(InstrD[31:7]),
    .ImmSrc(ImmSrc),
    .ImmExt(ImmExtD)
);

endmodule