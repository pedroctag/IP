module E_M_flipflop (
    input clk,
    input reset,
    input RegWriteE,
    input MemWriteE,
    input [1:0] ResultSrcE,
    input [4:0] RdE,
    input [31:0] PCPlus4E,
    input [31:0] WriteDataE,
    input [31:0] Result,
    output reg RegWriteM,
    output reg MemWriteM,
    output reg [1:0] ResultSrcM,
    output reg [4:0] RdM,
    output reg [31:0] ALUResultM,
    output reg [31:0] WriteDataM,
    output reg [31:0] PCPlus4M
);

always @ (posedge clk or posedge reset)
begin
    if (reset) {RegWriteM, MemWriteM, ResultSrcM, RdM, ALUResultM, WriteDataM, PCPlus4M} <= 0;
    else
    begin
        RegWriteM <= RegWriteE;
        MemWriteM <= MemWriteE;
        ResultSrcM <= ResultSrcE;
        RdM <= RdE;
        ALUResultM <= Result;
        WriteDataM <= WriteDataE;
        PCPlus4M <= PCPlus4E;
    end
end

endmodule