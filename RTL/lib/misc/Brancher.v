module Brancher(
    input JumpE, //Flag de Jump vinda do estágio execute
    input BranchE, //Flag de Branch vinda do estágio execute
    input [2:0] funct3E,
    input Zero, //Flag de Zero vinda da ULA
    input Negative, //Flag de Negative vinda da ULA
    output reg PCSrcE // Sinal de controle do Mux para selecionar prox. endereço
);

always @(*) begin
    PCSrcE = 0;
    if(JumpE) PCSrcE = 1;
    else if(BranchE) begin
        case(funct3E)
        3'b000: PCSrcE = Zero;        //BEQ
        3'b001: PCSrcE = ~Zero;       //BNE
        3'b100: PCSrcE = Negative;    //BLT
        3'b101: PCSrcE = ~Negative;   //BGE
        default: PCSrcE = 0;
        endcase
    end
end

endmodule