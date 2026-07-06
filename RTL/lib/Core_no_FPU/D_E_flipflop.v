module D_E_flipflop (
    input clk,
    input reset,
    input RegWriteD,
    input MemWriteD,
    input JumpD,
    input BranchD,
    input ALUSrcD,
    input CLR,
    input [1:0] ResultSrcD,
    input [3:0] ALUControlD,
    input [4:0] Rs1D,
    input [4:0] Rs2D,
    input [4:0] RdD,
    input [31:0] PCD,
    input [31:0] PCPlus4D,
    input [31:0] RD1D,
    input [31:0] RD2D,
    input [31:0] ImmExtD,
    output reg RegWriteE,
    output reg MemWriteE,
    output reg JumpE,
    output reg BranchE,
    output reg ALUSrcE,
    output reg [1:0] ResultSrcE,
    output reg [3:0] ALUControlE,
    output reg [4:0] Rs1E,
    output reg [4:0] Rs2E, 
    output reg [4:0] RdE,
    output reg [31:0] PCE,
    output reg [31:0] PCPlus4E,
    output reg [31:0] RD1E,
    output reg [31:0] RD2E,
    output reg [31:0] ImmExtE
);

always @ (posedge clk or posedge reset)
begin
    if (reset | CLR) {RegWriteE, ResultSrcE, MemWriteE, JumpE, BranchE, ALUControlE, ALUSrcE, RD1E, RD2E, PCE, RdE, ImmExtE, PCPlus4E, Rs1E, Rs2E} <= 0;
    else
    begin
        RegWriteE <= RegWriteD;
        ResultSrcE <= ResultSrcD;
        MemWriteE <= MemWriteD;
        JumpE <= JumpD;
        BranchE <= BranchD;
        ALUControlE <= ALUControlD;
        ALUSrcE <= ALUSrcD;
        RD1E <= RD1D;
        RD2E <= RD2D;
        PCE <= PCD;
        RdE <= RdD;
        ImmExtE <= ImmExtD;
        PCPlus4E <= PCPlus4D;
        Rs1E <= Rs1D;
        Rs2E <= Rs2D;
    end
end

endmodule