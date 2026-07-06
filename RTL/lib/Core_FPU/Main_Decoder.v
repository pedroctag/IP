module Main_Decoder (
    input [6:0] op,
    input [4:0] funct5,
    output reg Branch,
    output reg Upper,
    output reg Jump,
    output reg [1:0] ResultSrc, // mux de WB, um bit a mais por conta do jal
    output reg MemWrite,
    output reg ALUSrc,
    output reg [2:0] ImmSrc,
    output reg RegWrite,
    output reg [1:0] ALUOp,
    output reg RegWriteF, // WE RFF
    output reg MemSrc, // Seletor mux da memória
    output reg DSrc, // Seletor mux da saída ULA/FPU
    output reg JumpR // Seletor mux da entrada PC (Retorno de jal)
    );

always @ (*)
begin
    // Ver tabela com códigos das novas instruções
    casex (op)
        7'b0000011: begin //lw
            RegWrite = 1;
            ImmSrc = 3'b000;
            ALUSrc = 1;
            Upper = 0;
            MemWrite = 0;
            ResultSrc = 2'b01;
            Branch = 0;
            ALUOp = 2'b00;
            // referente a FPU
            RegWriteF = 0;
            MemSrc = 0;
            DSrc = 0;
            Jump = 1'b0;
            JumpR = 1'b0;
        end
        7'b0100011: begin //sw
            RegWrite = 0;
            ImmSrc = 3'b001;
            ALUSrc = 1;
            Upper = 0;
            MemWrite = 1;
            ResultSrc = 2'b01;
            Branch = 0;
            ALUOp = 2'b00;
            // referente a FPU
            RegWriteF = 0;
            MemSrc = 0;
            DSrc = 0;
            Jump = 1'b0;
            JumpR = 1'b0;
        end
        7'b0110011: begin //r-type
            RegWrite = 1;
            ImmSrc = 3'bxxx;
            ALUSrc = 0;
            Upper = 0;
            MemWrite = 0;
            ResultSrc = 2'b00;
            Branch = 0;
            ALUOp = 2'b10;
            // referente a FPU
            RegWriteF = 0;
            MemSrc = 0;
            DSrc = 0;
            Jump = 1'b0;
            JumpR = 1'b0;
        end
        7'b1100011: begin //beq
            RegWrite = 0;
            ImmSrc = 3'b010;
            ALUSrc = 0;
            Upper = 0;
            MemWrite = 0;
            ResultSrc = 2'b00;
            Branch = 1;
            ALUOp = 2'b01;
            // referente a FPU
            RegWriteF = 0;
            MemSrc = 0;
            DSrc = 0;
            Jump = 1'b0;
            JumpR = 1'b0;
        end
        7'b0010011: begin // I-type
            RegWrite = 1'b1;
            ImmSrc = 3'b000; // Immediate source
            ALUSrc = 1'b1; // ALU source is immediate
            Upper = 0;
            MemWrite = 1'b0; // No memory write
            ResultSrc = 2'b00; // Result comes from ALU
            Branch = 0; // No branching
            ALUOp = 2'b10; // ALU operation for I-type instructions
            // referente a FPU
            RegWriteF = 0;
            MemSrc = 0;
            DSrc = 0;
            Jump = 1'b0;
            JumpR = 1'b0;
        end
        7'b1101111: begin // Jal
            RegWrite = 1'b1;
            ImmSrc = 3'b011; // Immediate source
            ALUSrc = 1'b0; // ALU source is immediate
            Upper = 0;
            MemWrite = 1'b0; // No memory write
            ResultSrc = 2'b10; // Result comes from ALU
            Branch = 0; // No branching
            ALUOp = 2'b00; // ALU operation for I-type instructions
            RegWriteF = 0;
            MemSrc = 0;
            DSrc = 0;
            Jump = 1'b1;
            JumpR = 1'b0;
        end
        7'b1100111: begin // Jalr
            RegWrite = 1'b0;
            ImmSrc = 3'b000; // Immediate source
            ALUSrc = 1'b1; // ALU source is immediate
            Upper = 0;
            MemWrite = 1'b0; // No memory write
            ResultSrc = 2'b10; // Result comes from ALU
            Branch = 0; // No branching
            ALUOp = 2'b00; // ALU operation for I-type instructions
            RegWriteF = 0;
            MemSrc = 0;
            DSrc = 0;
            Jump = 1'b1;
            JumpR = 1'b1;
        end
        7'b0110111: begin // U-Type
            RegWrite = 1'b1;
            ImmSrc = 3'b100; // Immediate source
            ALUSrc = 1'b1; // ALU source is immediate
            Upper = 1;
            MemWrite = 1'b0; // No memory write
            ResultSrc = 2'b00; // Result comes from ALU
            Branch = 0; // No branching
            ALUOp = 2'b00; // ALU operation for I-type instructions
            RegWriteF = 0;
            MemSrc = 0;
            DSrc = 0;
            Jump = 1'b0;
            JumpR = 1'b0;
        end

        // SEÇÃO DE INSTRUCÕES F (OLHAR QUAIS SÃO OS SINAIS)
        7'b0000111: begin // flw
        // mux de saída precisa selecionar a FPU
            RegWrite = 0;
            ImmSrc = 3'b000;
            ALUSrc = 1;
            Upper = 0;
            MemWrite = 0;
            ResultSrc = 2'b01;
            Branch = 0;
            ALUOp = 2'b00;

            RegWriteF = 1;
            MemSrc = 1'bx; // Indiferente
            DSrc = 0;
            Jump = 1'b0;
            JumpR = 1'b0;
        end
        7'b0100111: begin //fsw
        // mux da memória precisa selecionar a FPU
            RegWrite = 0;
            ImmSrc = 3'b001;
            ALUSrc = 1;
            Upper = 0;
            MemWrite = 1;
            ResultSrc = 2'b01;
            Branch = 0;
            ALUOp = 2'b00;

            RegWriteF = 0;
            MemSrc = 1; // Tem de ser 1 pois escreve na memória
            DSrc = 0;
            Jump = 1'b0;
            JumpR = 1'b0;
        end
        7'b1010011: begin // Tipo fp (Análogo ao R)
            RegWrite = 0;
            ImmSrc = 3'bxxx; // Indiferente. Imediato não utilizado
            ALUSrc = 1'bx; // Indiferente. ULA não utilizada
            Upper = 0;
            MemWrite = 0; // Não há necessidade de escrever na memória
            ResultSrc = 2'b00; // Resultado vem do conjunto FPU/ULA
            Branch = 0;
            ALUOp = 2'b00; // Indiferente. ULA não utilizada
            Jump = 1'b0;
            JumpR = 1'b0;
            case (funct5)
                5'b11010: // instrução fcvt.s.w precisa disso, pois só difere no funct 5 das outras Fp
                begin
                    RegWrite = 0;
                    RegWriteF = 1;
                    MemSrc = 1'bx;
                    DSrc = 1;
                end
                5'b11000: // ( fcvt.w.s)
                begin
                    RegWrite = 1;
                    RegWriteF = 0;
                    MemSrc = 1'bx;
                    DSrc = 1;
                end
                5'b11110: // fmv w.x
                begin
                    RegWrite = 0;
                    RegWriteF = 1;
                    MemSrc = 1'bx;
                    DSrc = 1;
                end
                5'b11100: //fmv x.w
                begin
                    RegWrite = 1;
                    RegWriteF = 0;
                    MemSrc = 1'bx;
                    DSrc = 1;
                end
                default: // Outras instruções FP
                begin
                    RegWrite = 0;
                    RegWriteF = 1; // Escreve o resultado no registrador F
                    MemSrc = 1'bx; // Memória não utilizada
                    DSrc = 1;
                end
            endcase
        end
        default: begin
            RegWrite = 0;
            ImmSrc = 3'bxxx;
            ALUSrc = 0;
            MemWrite = 0;
            ResultSrc = 2'b00;
            Branch = 0;
            ALUOp = 2'b00;
            RegWriteF = 0;
            Upper = 0;
            DSrc = 0;
            MemSrc = 0;
            Jump = 1'b0;
            JumpR = 1'b0;
        end
    endcase
end
endmodule