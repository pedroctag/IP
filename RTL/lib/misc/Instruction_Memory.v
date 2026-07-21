module Instruction_Memory(
    // Para UVM e Síntese
    input we,
    input [31:0] WA,
    input [31:0] din,

	  input [31:0] 	A,
    //input [31:0] A2,
		output [31:0] RD
    //output [31:0] RD2
		);
   reg [31:0] instruction [0:1023]; // 1kb
   integer i;

   initial
     begin
    for (i = 0; i < 1023; i = i + 1) instruction[i] = 32'b0;
   // $readmemh("C://Users//Pedro//Desktop//IP//RTL//lib//Core_FPU//instruction.txt", instruction);
     end

    always @ (*)
      if (we) instruction[WA[31:2]] = din; // word aligned
      else instruction[WA[31:2]] = instruction[WA[31:2]]; // word aligned

   assign RD = (we) ? 32'b0 : instruction[A[31:2]]; // word aligned
   //assign RD2 = instruction[A2[31:2]];

endmodule
