module D_E_flipflop (
    input clk,
    input reset,
    input RegWriteD,
    input RegWriteFD,
    input MemWriteD,
    input JumpD,
    input MemSrc,
    input BranchD,
    input ALUSrcD,
    input JumpRD,
    input CLR,
    input FPUAinSelD,
    input [1:0] ResultSrcD,
    input [2:0] funct3D,
    input [3:0] ALUControlD,
    input [4:0] selFPUD,
    input [4:0] Rs1D,
    input [4:0] Rs2D,
    input [4:0] RdD,
    input [31:0] PCD,
    input [31:0] PCPlus4D,
    input [31:0] RD1D,
    input [31:0] RD2D,
    input [31:0] RDF1D,
    input [31:0] RDF2D,
    input [31:0] ImmExtD,
    output reg RegWriteE,
    output reg RegWriteFE,
    output reg MemWriteE,
    output reg JumpE,
    output reg JumpRE,
    output reg BranchE,
    output reg MemSrcE,
    output reg ALUSrcE,
    output reg FPUAinSelE,
    output reg [1:0] ResultSrcE,
    output reg [2:0] funct3E,
    output reg [3:0] ALUControlE,
    output reg [4:0] selFPUE,
    output reg [4:0] Rs1E,
    output reg [4:0] Rs2E,
    output reg [4:0] RdE,
    output reg [31:0] PCE,
    output reg [31:0] PCPlus4E,
    output reg [31:0] RD1E,
    output reg [31:0] RD2E,
    output reg [31:0] RDF1E,
    output reg [31:0] RDF2E,
    output reg [31:0] ImmExtE
);

always @ (posedge clk or posedge reset)
begin
    if (reset) // 1. Condição de Reset Assíncrono estrita (Exigência das ferramentas de síntese)
    begin
        {RegWriteE, funct3E, JumpRE, FPUAinSelE, selFPUE, MemSrcE, RDF1E, RDF2E, ResultSrcE, MemWriteE, JumpE, BranchE, ALUControlE, ALUSrcE, RD1E, RD2E, PCE, RdE, ImmExtE, PCPlus4E, Rs1E, Rs2E, RegWriteFE} <= 0;
    end
    else if (CLR) // 2. Condição de Flush/Clear Síncrono (Avaliado apenas na borda do clock)
    begin
        {RegWriteE, funct3E, JumpRE, FPUAinSelE, selFPUE, MemSrcE, RDF1E, RDF2E, ResultSrcE, MemWriteE, JumpE, BranchE, ALUControlE, ALUSrcE, RD1E, RD2E, PCE, RdE, ImmExtE, PCPlus4E, Rs1E, Rs2E, RegWriteFE} <= 0;
    end
    else // 3. Comportamento normal de atualização da pipeline
    begin
        RegWriteE   <= RegWriteD;
        ResultSrcE  <= ResultSrcD;
        MemWriteE   <= MemWriteD;
        JumpE       <= JumpD;
        BranchE     <= BranchD;
        ALUControlE <= ALUControlD;
        ALUSrcE     <= ALUSrcD;
        RD1E        <= RD1D;
        RD2E        <= RD2D;
        RDF1E       <= RDF1D;
        RDF2E       <= RDF2D;
        PCE         <= PCD;
        RdE         <= RdD;
        ImmExtE     <= ImmExtD;
        PCPlus4E    <= PCPlus4D;
        Rs1E        <= Rs1D;
        Rs2E        <= Rs2D;
        MemSrcE     <= MemSrc;
        RegWriteFE  <= RegWriteFD;
        selFPUE     <= selFPUD;
        FPUAinSelE  <= FPUAinSelD;
        funct3E     <= funct3D;
        JumpRE      <= JumpRD;
    end
end

endmodule