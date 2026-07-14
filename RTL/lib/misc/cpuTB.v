module cpuTB();

reg clk, rst;
reg we;
reg [31:0] WA;
reg [31:0] din;
reg [31:0] instr_file[0:1024];
wire [4:0] RdW;
wire [31:0] ResultW;
wire [31:0] ALUResultM;
wire [31:0] WriteDataM;
wire MemWriteM;
//wire scan_out;
//reg  scan_in, SE;

integer i;
reg [31:0] inst_file [0:1024];

pipelined_processor_FPU dut (
    .clk(clk),
    .reset(rst),
    .we(we),
    .WA(WA),
    .din(din),
    .RdW(RdW),
    .ALUResultM(ALUResultM),
    .WriteDataM(WriteDataM),
    .MemWriteM(MemWriteM),
    .ResultW(ResultW)
);

initial
begin
    $readmemh("/home/aluno/IP/RTL/lib/misc/arbinstr.txt", instr_file);

    clk = 0;
    rst = 1;
    we = 0;
    #10;

    // Load instruction memory through the din interface, one word at a time
    for (i = 0; i < 1024; i = i + 1) begin
        WA = i * 4;     // word-aligned address
        din  = instr_file[i];
        we   = 1;
        #10;
    end

    we = 0;
    #10;
    rst = 0;
    #7000 $finish;
end

always #5 clk = ~clk;

/*`ifdef SDF
begin
    $sdf_annotate("Sim/sdf/delays_PPA2.sdf", pipelined_processor_FPU.dut,,"../../../SYNTHESIS/Sim/sdf/sdf.log", "MAXIMUM");
end
`endif*/

endmodule