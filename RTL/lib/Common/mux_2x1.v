module mux_2x1(
    input [31:0] inA,
    input [31:0] inB,
    input  sel,
    output [31:0] out
);

assign out = (sel == 1'b0) ? inA : inB;

endmodule