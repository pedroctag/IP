module mux_4x1(
    input [3:0] inA,
    input [3:0] inB,
    input [3:0] inC,
    input [3:0] inD,
    input [1:0] sel,
    output [3:0] out
);

assign out = (sel == 2'b00) ? inA : ((sel == 2'b01) ? inB : ((sel == 2'b10) ? inC : inD));

endmodule