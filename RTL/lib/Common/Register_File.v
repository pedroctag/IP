module Register_File(
	input wire 	clk, WE3,
	input wire [4:0] RA1,RA2,WA3,
	input wire [31:0] WD3,
	output wire [31:0] RD1,RD2
);

reg [31:0] REG_MEM_BLOCK[0:31];

initial
begin
	REG_MEM_BLOCK[0] = 32'b0;
end

always@(negedge clk)
begin
	if(WE3 && (WA3 != 0))
	REG_MEM_BLOCK[WA3] <= WD3;
end

assign RD1 = REG_MEM_BLOCK[RA1];
assign RD2 = REG_MEM_BLOCK[RA2];

endmodule
