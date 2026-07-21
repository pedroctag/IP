module align_tb;
reg [31:0] Instr;
reg [31:0] NextInstr;
reg PC1;
wire isCompressed;
wire [15:0] HalfWord;

InstructionAlign align (
    .Instr(Instr),
    .NextInstr(NextInstr),
    .PC1(PC1),
    .isCompressed(isCompressed),
    .HalfWord(HalfWord)
);

initial begin

    Instr = 32'h00000003; // 32
    NextInstr = 32'h11111111; 
    PC1 = 0;
    #10;

    Instr = 32'h00030000; //16 com baixa compressed
    NextInstr = 32'h11111111;
    PC1 = 0;
    #10;


    Instr = 32'h00030003; // 32
    NextInstr = 32'h11111111;
    PC1 = 0;
    #10;

    Instr = 32'h22220000; // 16 com ambas compressed
    NextInstr = 32'h11111111;
    PC1 = 0;
    #10; 


    Instr = 32'h00000003; // 16 com baixa compressed
    NextInstr = 32'h11101111;
    PC1 = 1;
    #10;

    
    Instr = 32'h00030000; // 32
    NextInstr = 32'h00030000; 
    PC1 = 1;
    #10;

    Instr = 32'h00030003; // 32
    NextInstr = 32'h00030000;
    PC1 = 1;
    #10;

    Instr = 32'h10000000; // 16 com ambas compressed
    NextInstr = 32'h22222222;
    PC1 = 1;
    #10; 





    Instr = 32'h00000000;
    NextInstr = 32'h00000000;
    PC1 = 0;
    #30;
    





    Instr = 32'h000000003; // 32
    NextInstr = 32'h00000003; // 32
    PC1 = 0;
    #10;

    Instr = 32'h000000003; // 32
    NextInstr = 32'h00010001; // 16 dupla
    PC1 = 0;
    #10;
    
    Instr = 32'h00010021; // 16 dupla
    NextInstr = 32'h00000003; // 32
    PC1 = 0;
    #10;

    Instr = 32'h00010001; // 16 dupla
    NextInstr = 32'h00000003; // 32
    PC1 = 1;
    #10;

    Instr = 32'h00000003; // 32
    NextInstr = 32'h10003330; // 16 alta + 1/2 32
    PC1 = 0;
    #10;

    Instr = 32'h10003330; // 16 alta + 1/2 32
    NextInstr = 32'h33330000; // 16 baixa + 1/2 32
    PC1 = 0;
    #10;

    Instr = 32'h10003330; // 16 alta + 1/2 32
    NextInstr = 32'h33330000; // 1/2 32 +  16 baixa
    PC1 = 1;
    #10;

    Instr = 32'h33330000; // 1/2 32 +  16 baixa
    NextInstr = 32'h00000003; // 32
    PC1 = 1;
    #10;

    Instr = 32'h00000003; // 32
    NextInstr = 32'h00000003; // 32
    PC1 = 0;
    #10;

    $finish; // End the simulation
end
endmodule