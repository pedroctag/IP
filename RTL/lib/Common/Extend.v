module Extend(
	input wire [31:7]  Instr,
	input wire [2:0] 	 ImmSrc, 
	output wire [31:0] ImmExt );
   
reg [31:0] 			 ImmExtReg;
   
always@(*)
  case(ImmSrc)
  //I-type
  3'b000:begin      
        if (Instr[14:12] == 3'b001 || Instr[14:12] == 3'b101) ImmExtReg = {27'b0, Instr[24:20]}; //srai, slli, srlai
        else ImmExtReg = {{20{Instr[31]}}, Instr[31:20]}; // I comum
        end
  3'b001: ImmExtReg = {{20{Instr[31]}},Instr[31:25],Instr[11:7]};//S-type(stores)
  3'b010: ImmExtReg = {{20{Instr[31]}},Instr[7],Instr[30:25],Instr[11:8],1'b0}; //B-type(branches)
  3'b011: ImmExtReg = {{12{Instr[31]}},Instr[19:12],Instr[20],Instr[30:21],1'b0};//J-type(jal)
  3'b100: ImmExtReg = {Instr[31:12], 12'b0};
  default: ImmExtReg = 32'bx; //undefined
  endcase
   
assign ImmExt = ImmExtReg;

endmodule
