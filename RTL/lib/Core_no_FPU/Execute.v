module Execute (
    input ALUSrc,
    input [3:0] ALUControl,
    input [31:0] RD1E,
    input [31:0] RD2E,
    input [31:0] ImmExtE,
    input [31:0] PCE,
    output Zero,
    output [31:0] WriteDataE,
    output [31:0] Result,
    output [31:0] PCTargetE
);

wire [31:0] SrcBE;

assign WriteDataE = RD2E;

ALU ALU (
    .A(RD1E),
    .B(SrcBE),
    .ALUControl(ALUControl),
    .Zero(Zero),
    .Result(Result)
);

PC_Target PC_Branch_adder(
    .PC(PCE),
    .ImmExt(ImmExtE),
    .PCTarget(PCTargetE)
);

mux_2x1 ALU_mux (
    .inA(RD2E),
    .inB(ImmExtE),
    .sel(ALUSrc),
    .out(SrcBE)
);

endmodule