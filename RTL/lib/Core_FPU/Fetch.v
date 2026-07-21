module Fetch (
    input clk,
    input reset,
    input PCSrc,
    input EN,
    input JumpR,
    input [31:0] Imm,
    input [31:0] PCE,
    input [31:0] Result,
    output isCompressedA,
    output [31:0] InstrF,
    output [31:0] PCF,
    output [31:0] PCPlus4F,

    // Para UVM e Síntese
    input we,
    input [31:0] WA,
    input [31:0] din
);

wire [31:0] PClF;

Instruction_Memory IM (
    .A(PCF),
    .RD(InstrF),

    .we(we),
    .WA(WA),
    .din(din)
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
    .Imm(Imm),
    .PCSrc(PCSrc),
    .isCompressed(isCompressedA),
    .PCE(PCE),
    .PCPlus4(PCPlus4F)
);

mux_2x1 PC_Mux(
    .inA(PCPlus4F),
    .inB(Result),
    .sel(JumpR),
    .out(PClF)
);

Cflag CompressedFlag (
    .PC1(PCF),
    .isCompressedA(isCompressedA),
    .InstructionPF(InstrF)
);

endmodule