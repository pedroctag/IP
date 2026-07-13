module Writeback (
    input [1:0] ResultSrc,
    input [31:0] ALUResultW,
    input [31:0] PCPlus4W,
    input [31:0] ReadDataW,
    output [31:0] ResultW
);

mux_3x1 Mux_WriteBack (
    .inA(ALUResultW),
    .inB(ReadDataW),
    .inC(PCPlus4W),
    .sel(ResultSrc),
    .out(ResultW)
);

endmodule