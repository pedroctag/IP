module multiply_tb();
reg [31:0] iA;
reg [31:0] iB;
wire [31:0] oProd;

multiply dut (
    .iA(iA),
    .iB(iB),
    .oProd(oProd)
);

initial begin
    iA = 32'h478ccd00; // resultado deu -1
    iB = 32'h37800074;
    #10;

    iA = 32'h48200000; // resultado deu certo
    iB = 32'h37800074;
    #10;

    iA = 32'hc8700000; // resultado deu -1
    iB = 32'h37800074;
    #10;

    iA = 32'h48840000; // resultado deu -1
    iB = 32'h37800074;
    #10;
    $stop;
end

endmodule