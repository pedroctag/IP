module InstructionAlign (
    input [31:0] Instr,
    input [31:0] NextInstr,
    input PC1,
    output [15:0] HalfWord,
    output [31:0] ManipulatedInstruction
);

assign ManipulatedInstruction = (PC1) ? {NextInstr[15:0],Instr[31:16]} : Instr;
assign HalfWord = (PC1) ? Instr[31:16] : Instr[15:0];

endmodule