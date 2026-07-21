module PreFetchBuffer_tb;
reg clk;
reg [31:0] InstructionPF;
wire [31:0] InstructionA;
wire [31:0] InstructionB;
PreFetchBuffer PFB (
    .clk(clk),
    .InstructionPF(InstructionPF),
    .InstructionA(InstructionA),
    .InstructionB(InstructionB)
);

always #10 clk = ~clk;

initial begin
    clk = 0;
    InstructionPF = 32'h00000000; // Initial value
    #100; // Wait for 10 time units

    // Test case 1: Update InstructionPF and check outputs
    InstructionPF = 32'h12345678;
    #100; // Wait for 10 time units
    
    // Test case 2: Update InstructionPF again and check outputs
    InstructionPF = 32'h87654321;
    #100; // Wait for 10 time units
   
    InstructionPF = 32'hFFFFFFFF;
    #100; // Wait for 10 time units

    InstructionPF = 32'hAAAAAAAA;
    #10; // Wait for 10 time units
    $finish; // End the simulation
end
endmodule