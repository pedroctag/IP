module Decompressor (
    input isCompressed,
    input [15:0] HalfWord,
    input [31:0] Instruction,
    output reg [31:0] InstrCOMPLETE
);

always @(*)
begin
    if (isCompressed)
    begin
        case(HalfWord[1:0])
            2'b01:
            begin
                case(HalfWord[15:13])
                    3'b000: InstrCOMPLETE = {{7{HalfWord[12]}}, HalfWord[6:2], HalfWord[11:7], 3'b000, HalfWord[11:7], 7'b0010011}; // C.ADDI
                    3'b010: InstrCOMPLETE = {{7{HalfWord[12]}}, HalfWord[6:2], 5'b00000, 3'b000, HalfWord[11:7], 7'b0010011}; // C.LI
                    3'b011: InstrCOMPLETE = {{15{HalfWord[12]}}, HalfWord[6:2], HalfWord[11:7], 7'b0110111 }; // C.LUI
                    3'b100:
                    begin
                        if (HalfWord[11:10] == 2'b10)
                            InstrCOMPLETE = {{{7{HalfWord[12]}}, HalfWord[6:2]}, {2'b01, HalfWord[9:7]}, 3'b111, {2'b01, HalfWord[9:7]}, 7'b0010011}; // C.ANDI
                        else
                            case ({HalfWord[12], HalfWord[6:5]})
                                3'b000: InstrCOMPLETE = {7'b0100000, {2'b01, HalfWord[4:2]}, {2'b01, HalfWord[9:7]}, 3'b000, {2'b01, HalfWord[9:7]}, 7'b0110011}; // C.SUB
                                3'b001: InstrCOMPLETE = {7'b0000000, {2'b01, HalfWord[4:2]}, {2'b01, HalfWord[9:7]}, 3'b100, {2'b01, HalfWord[9:7]}, 7'b0110011}; // C.XOR
                                3'b010: InstrCOMPLETE = {7'b0000000, {2'b01, HalfWord[4:2]}, {2'b01, HalfWord[9:7]}, 3'b110, {2'b01, HalfWord[9:7]}, 7'b0110011}; // C.OR
                                3'b011: InstrCOMPLETE = {7'b0000000, {2'b01, HalfWord[4:2]}, {2'b01, HalfWord[9:7]}, 3'b111, {2'b01, HalfWord[9:7]}, 7'b0110011}; // C.AND
                                default: InstrCOMPLETE = Instruction; 
                            endcase
                    end
                    default: InstrCOMPLETE = Instruction;
                endcase
            end
            2'b00:
            begin
                case(HalfWord[15:13])
                    3'b010: InstrCOMPLETE = {5'b00000, HalfWord[5], HalfWord[12:10], HalfWord[6], 2'b00, {2'b01, HalfWord[9:7]}, 3'b010, {2'b01, HalfWord[4:2]}, 7'b0000011}; // C.LW
                    3'b110: InstrCOMPLETE = {5'b00000, HalfWord[5], HalfWord[12], {2'b01, HalfWord[4:2]}, {2'b01, HalfWord[9:7]}, 3'b010, HalfWord[11:10], HalfWord[6], 2'b00, 7'b0100011}; // C.SW
                    default: InstrCOMPLETE = Instruction;
                endcase
            end

            2'b10:
            begin
                case(HalfWord[15:13])
                    3'b100: // C.ADD e C.MV 
                    begin
                        InstrCOMPLETE = {7'b0000000, HalfWord[6:2], HalfWord[11:7], 3'b000, HalfWord[11:7], 7'b0110011}; 
                    end
                    3'b000:
                    begin
                        InstrCOMPLETE = {7'b0000000, HalfWord[12], HalfWord[6:2], HalfWord[11:7], 3'b001, HalfWord[11:7], 7'b0010011};
                    end
                    default: InstrCOMPLETE = Instruction;
                endcase
            end
            default: InstrCOMPLETE = Instruction;
        endcase
    end
    else InstrCOMPLETE = Instruction;
end

endmodule