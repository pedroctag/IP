module Execute (
    input ALUSrc,
    input MemSrc,
    input [3:0] ALUControl,
    input [4:0]selFPU,
    input [31:0] RD1E,
    input [31:0] RD2E,
    input [31:0] RDF1E,
    input [31:0] RDF2E,
    input [31:0] ImmExtE,
    //input [31:0] PCE,
    output Zero,
    output Negative,
    output [31:0] WriteDataXE,
    output [31:0] WriteDataFE,
    output [31:0] Result
    //output [31:0] PCTargetE
);

wire [31:0] SrcBE;
wire [31:0] ALUResult;
wire [31:0] FPUResult;

assign WriteDataXE = RD2E;
assign WriteDataFE = RDF2E;

ALU ALU (
    .A(RD1E),
    .B(SrcBE),
    .ALUControl(ALUControl),
    .Zero(Zero),
    .Negative(Negative),
    .Result(ALUResult)
);

/*PC_Target PC_Branch_adder (
    .PC(PCE),
    .ImmExt(ImmExtE),
    .PCTarget(PCTargetE)
);*/

mux_2x1 ALU_mux (
    .inA(RD2E),
    .inB(ImmExtE),
    .sel(ALUSrc),
    .out(SrcBE)
);

FPU FPU (
    .A(RDF1E),
    .B(RDF2E),
    .sel(selFPU),
    .Result(FPUResult)
);

mux_2x1 ALU_FPU_mux (
    .inA(ALUResult),
    .inB(FPUResult),
    .sel(MemSrc),
    .out(Result)
);
endmodule