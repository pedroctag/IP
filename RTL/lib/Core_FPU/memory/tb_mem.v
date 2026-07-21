module tb_mem();

reg clk;

reg [1:0] size;
reg [5:0] addr;
reg [31:0] din;
reg sign_ext;
reg writeEnable;

wire [31:0] dout;

memTopo32LittleEndian DUT(
    .clk(clk),
    .size(size),
    .addr(addr),
    .din(din),
    .sign_ext(sign_ext),
    .writeEnable(writeEnable),
    .dout(dout)
);

always #5 clk=~clk;

initial begin

clk=0;

size=0;
addr=0;
din=0;
sign_ext=0;
writeEnable=0;

#20;
size=2'b10;
addr=0;din=32'h11223344;
writeEnable=1;

#10;
writeEnable=0;

#10;
addr=0;

#10;
size=2'b00;
addr=0;
din=32'h000000AA;
writeEnable=1;

#10;
writeEnable=0;

#10;
addr=0;
sign_ext=1;

#10;
size=2'b00;
addr=1;
din=32'h00000055;
writeEnable=1;

#10;
writeEnable=0;

#10;
addr=0;
size=2'b00; // sb

#10;
addr=3;
din=32'h00000099;
writeEnable=1;

#10;
writeEnable=0;

#10;
size=2'b10;
addr=0;

#10;
size=2'b01;
addr=6;
din=32'h00001234;
writeEnable=1;

#10;
writeEnable=0;

#10;
size=2'b10;
addr=4;

#10;
size=2'b01;
addr=6;
sign_ext=0;

#10;
size=2'b01;
addr=8;
din=32'h0000FFF0;
writeEnable=1;

#10;
writeEnable=0;

#10;
size=2'b01;
addr=8;
sign_ext=1;

#10;
size=2'b10;
addr=3;
din=32'hDEADBEEF;
writeEnable=1;

#10;
writeEnable=0;

#10;
addr=3;

#50;
$finish;
end


endmodule