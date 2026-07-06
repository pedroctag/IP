module F_D_flipflop(
    input clk,
    input reset,
    input isCompressed,
    input EN,
    input CLR,
    input [31:0] InstrF,
    input [31:0] PCPlus4F,
    input [31:0] PCF,
    output reg isCompressedD,
    output reg [31:0] InstrD,
    output reg [31:0] PCPlus4D,
    output reg [31:0] PCD
);

always @ (posedge clk or posedge reset)
begin
    if (reset | CLR) {isCompressedD, InstrD, PCPlus4D, PCD} <= 0;
    else if (~EN)
    begin
        InstrD <= InstrF;
        PCPlus4D <= PCPlus4F;
        PCD <= PCF;
        isCompressedD <= isCompressed;
    end
end
endmodule