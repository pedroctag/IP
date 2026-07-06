module M_W_flipflop (
    input clk,
    input reset,
    input RegWriteM,
    input RegWriteFM,
    input [1:0] ResultSrcM,
    input [4:0] RdM,
    input [31:0] ALUResultM,
    input [31:0] PCPlus4M,
    input [31:0] RD,
    output reg RegWriteW,
    output reg RegWriteFW,
    output reg [1:0] ResultSrcW,
    output reg [4:0] RdW,
    output reg [31:0] ALUResultW,
    output reg [31:0] PCPlus4W,
    output reg [31:0] ReadDataW
);

always @ (posedge clk or posedge reset)
begin
    if (reset) {RegWriteW, RegWriteFW, ResultSrcW, RdW, ALUResultW, PCPlus4W, ReadDataW} <= 0;
    else
    begin
        RegWriteW <= RegWriteM;
        ResultSrcW <= ResultSrcM;
        RdW <= RdM;
        ALUResultW <= ALUResultM;
        PCPlus4W <= PCPlus4M;
        ReadDataW <= RD;
        RegWriteFW <= RegWriteFM;
    end
end

endmodule