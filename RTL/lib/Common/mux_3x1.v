module mux_3x1(
    input [31:0] inA,
    input [31:0] inB,
    input [31:0] inC,
    input [1:0] sel,
    output [31:0] out
);

assign out = (sel == 2'b00) ? inA : ((sel == 2'b01) ? inB : ((sel == 2'b10) ? inC : 2'bxx));

endmodule