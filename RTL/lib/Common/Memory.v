module Memory (
    input clk,
    input WE,
    input [2:0] funct3M,
    input [31:0] ALUResultM,
    input [31:0] WriteDataM,
    output [31:0] RD
);

memTopo32LittleEndian dmemory (
  .clk(clk),
  .size(funct3M[1:0]),
  .addr(ALUResultM),
  .din(WriteDataM),
  .sign_ext(funct3M[2]),
  .writeEnable(WE),
  .dout(RD)
);


endmodule