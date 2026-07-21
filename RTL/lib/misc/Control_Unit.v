module Control_Unit(
    input wire [6:0] op,
    input wire [2:0] funct3,
    input wire [4:0] funct5,
    input wire [2:0] rm,
    input wire funct7b5, // function 7 is the 5th bit
    output wire [1:0] ResultSrc,
    output wire MemWrite,
    output wire FPUAinSel,
    output wire Upper,
    output wire Branch,
    output wire ALUSrc,
    output wire RegWrite,
    output wire RegWriteF,
    output wire MemSrc,
    output wire Jump,
    output wire ResultSel,
    output wire [4:0] selFPU,
    output wire [2:0] ImmSrc,
    output wire [3:0] ALUControl,
    output wire JumpR
);

wire [1:0] ALUop;
   
Main_Decoder maindecoder (
  .op(op),
  .Jump(Jump),
  .JumpR(JumpR),
  .Branch(Branch),
  .ResultSrc(ResultSrc),
  .Upper(Upper),
  .MemWrite(MemWrite),
  .ALUSrc(ALUSrc),
  .ImmSrc(ImmSrc),
  .RegWrite(RegWrite),
  .ALUOp(ALUop),
  .funct5(funct5),
  .RegWriteF(RegWriteF),
  .MemSrc(ResultSel), // inverti os nomes, não vou mexer por agora
  .DSrc(MemSrc) // teria de alterar algumas conexões, sem necessidade por enquanto
);
   
ALU_Decoder ALU_Decoder(
   .opb5(op[5]),
   .funct3(funct3),
   .funct7b5(funct7b5),
   .ALUOp(ALUop),
   .ALUControl(ALUControl)
);
   
FPU_Decoder fpudecoder (
  .funct5(funct5),
  .rm(rm),
  .FPUAinSel(FPUAinSel),
  .sel(selFPU)
);    
   
endmodule
