module Cflag (
    input [31:0] PC1,
    input [31:0] InstructionPF,
    output isCompressedA
);

assign isCompressedA = (PC1[1]) ? (InstructionPF[17:16] != 2'b11) : (InstructionPF[1:0] != 2'b11);

endmodule