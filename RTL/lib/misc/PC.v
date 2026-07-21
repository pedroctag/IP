module PC (	
		input clk,
    input reset,
		input [31:0] PCNext,
    //input [31:0] PCNextPlus2,
    input EN,
		output reg [31:0] PC
    //output reg [31:0] PCPlus2
    );
   
always@(posedge clk or posedge reset)
  begin
	  if (reset) 
    begin
      PC <= 0;
      //PCPlus2 <= 0;
    end
    else if(~EN)
      begin
        PC <= PCNext;
        //PCPlus2 <= PCNextPlus2;
      end
  end	


endmodule
