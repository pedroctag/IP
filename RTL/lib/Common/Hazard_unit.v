module Hazard_unit (
    input RegWriteW,
    input RegWriteM,
    input RegWriteFW,
    input RegWriteFM,
    input ResultSrcE,
    input PCSrcE,
    input [4:0] Rs1D,
    input [4:0] Rs2D,
    input [4:0] RdE,
    input [4:0] RdM,
    input [4:0] RdW,
    input [4:0] Rs1E,
    input [4:0] Rs2E,
    output reg lwStall,
    output reg FlushD,
    output reg FlushE,
    output reg [1:0] ForwardAE,
    output reg [1:0] ForwardBE
);

wire RWW;
wire RWM;

assign RWW = RegWriteW | RegWriteFW;
assign RWM = RegWriteM | RegWriteFM;

always@(*)
begin
    if (((Rs1E == RdM) & RWM) & (Rs1E != 0)) ForwardAE = 2'b10;
    else if(((Rs1E == RdW) & RWW) & (Rs1E != 0)) ForwardAE = 2'b01;
    else ForwardAE = 2'b00;

    if (((Rs2E == RdM) & RWM) & (Rs2E != 0)) ForwardBE = 2'b10;
    else if(((Rs2E == RdW) & RWW) & (Rs2E != 0)) ForwardBE = 2'b01;
    else ForwardBE = 2'b00;

    lwStall = ResultSrcE & ((Rs1D == RdE) | (Rs2D == RdE));
    FlushD = PCSrcE;
    FlushE = lwStall | PCSrcE;
end

endmodule