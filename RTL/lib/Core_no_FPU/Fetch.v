module Fetch (
    input clk,
    input reset,
    input PCSrc,
    input EN,
    input [31:0] PCTargetE,
    output [31:0] PCPlus4F,
    output [31:0] PCF,
    output [31:0] InstrF
);

wire [31:0] PClF;

Instruction_Memory IM (
    .A(PCF),
    .RD(InstrF)
);

PC PC_register(
    .clk(clk),
    .EN(EN),
    .reset(reset),
    .PCNext(PClF),
    .PC(PCF)
);

PC_Plus_4 PC_adder(
    .PC(PCF),
    .PCPlus4(PCPlus4F)
);

mux_2x1 PC_Mux(
    .inA(PCPlus4F),
    .inB(PCTargetE),
    .sel(PCSrc),
    .out(PClF)
);

endmodule