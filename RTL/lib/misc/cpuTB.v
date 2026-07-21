module cpuTB();

reg clk;
reg rst;

reg we;
reg [31:0] WA;
reg [31:0] din;

reg [31:0] instr_file [0:1023];

wire RegWriteW;
wire RegWriteFW;
wire [4:0] RdW;
wire [31:0] ResultW;
wire [31:0] WriteDataM;
wire [31:0] ALUResultM;
wire [31:0] InstrDC;
wire MemWriteM;

integer i;

pipelined_processor_FPU dut (
    .we(we),
    .WA(WA),
    .din(din),

    .RegWriteW(RegWriteW),
    .RegWriteFW(RegWriteFW),
    .RdW(RdW),
    .ResultW(ResultW),
    .WriteDataM(WriteDataM),
    .ALUResultM(ALUResultM),
    .InstrDC(InstrDC),
    .MemWriteM(MemWriteM),

    .clk(clk),
    .reset(rst)
);

initial
begin
    $readmemh("/home/aluno/IP/RTL/lib/misc/arbinstr.txt", instr_file);

    clk = 0;
    rst = 1;
    we = 0;
    #13;

    // Load instruction memory through the din interface, one word at a time
    for (i = 0; i < 1024; i = i + 1) begin
        WA = i * 4;     // word-aligned address
        din  = instr_file[i];
        #17;
        we = 1;
    end

    we = 0;
    #10;
    rst = 0;
    #6000;
end

always #10 clk = ~clk;

/*`ifdef SDF
begin
    $sdf_annotate("Sim/sdf/delays_PPA2.sdf", pipelined_processor_FPU.dut,,"../../../SYNTHESIS/Sim/sdf/sdf.log", "MAXIMUM");
end
`endif*/
initial begin
    // Substitua "instancia_do_processador" pelo nome real da instância no seu TB
    $sdf_annotate("/home/aluno/IP/SYNTHESIS/Sim/sdf/delays_PPA1.sdf", dut);
end
endmodule