module PC_Plus_4(
		input isCompressed,
		input PCSrc,
		input wire [31:0]  PC,
		input [31:0] Imm,
		input [31:0] PCE,
		output wire [31:0] PCPlus4
		//output wire [31:0] PCPlus4_Plus_2
		);


wire [31:0] A;
wire [31:0] B;

assign A = (PCSrc) ? Imm : PC;
assign B = (PCSrc) ? PCE : (isCompressed) ? 32'd2 : 32'd4;
assign PCPlus4 = A + B;
   //assign PCPlus4_Plus_2 = PCPlus4 + 32'd2;
endmodule
