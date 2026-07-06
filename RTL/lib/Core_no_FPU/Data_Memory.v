module Data_Memory(
		   input wire 	      clk, WE,
		   input wire [31:0]  A, WD,
		   output wire [31:0] RD
		   );

   reg [31:0] 			      RAM[0:63];

   assign RD = RAM[A[31:2]]; // word aligned

//only for testing, wont synthesize
//addi s0, zero, 0
//lw s0, 0(s0)
//lh s1, 0(s0)
//lb s2, 0(s0)
//sw s0, 63(s0)

/*initial begin
RAM[1]  = 32'd1;
RAM[2]  = 32'd2;
RAM[3]  = 32'd3;
RAM[4]  = 32'd4;
RAM[5]  = 32'd5;
RAM[6]  = 32'd6;
RAM[7]  = 32'd7;
RAM[8]  = 32'd8;
RAM[9]  = 32'd9;
RAM[10] = 32'd10;
RAM[11] = 32'd11;
RAM[12] = 32'd12;
RAM[13] = 32'd13;
RAM[14] = 32'd14;
RAM[15] = 32'd15;
RAM[16] = 32'd16;
RAM[17] = 32'd17;
RAM[18] = 32'd18;
RAM[19] = 32'd19;
RAM[20] = 32'd20;
RAM[21] = 32'd21;
RAM[22] = 32'd22;
RAM[23] = 32'd23;
RAM[24] = 32'd24;
RAM[25] = 32'd25;
RAM[26] = 32'd26;
RAM[27] = 32'd27;
RAM[28] = 32'd28;
RAM[29] = 32'd29;
RAM[30] = 32'd30;
RAM[31] = 32'd31;
RAM[32] = 32'd32;
RAM[33] = 32'd33;
RAM[34] = 32'd34;
RAM[35] = 32'd35;
RAM[36] = 32'd36;
RAM[37] = 32'd37;
RAM[38] = 32'd38;
RAM[39] = 32'd39;
RAM[40] = 32'd40;
RAM[41] = 32'd41;
RAM[42] = 32'd42;
RAM[43] = 32'd43;
RAM[44] = 32'd44;
RAM[45] = 32'd45;
RAM[46] = 32'd46;
RAM[47] = 32'd47;
RAM[48] = 32'd48;
RAM[49] = 32'd49;
RAM[50] = 32'd50;
RAM[51] = 32'd51;
RAM[52] = 32'd52;
RAM[53] = 32'd53;
RAM[54] = 32'd54;
RAM[55] = 32'd55;
RAM[56] = 32'd56;
RAM[57] = 32'd57;
RAM[58] = 32'd58;
RAM[59] = 32'd59;
RAM[60] = 32'd60;
RAM[61] = 32'd61;
RAM[62] = 32'd62;
RAM[63] = 32'd63;
end*/



   always @(posedge clk)
     if (WE)
       RAM[A[31:2]] <= WD;

endmodule
