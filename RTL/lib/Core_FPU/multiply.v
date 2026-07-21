module multiply (
    input  [31:0] iA,
    input  [31:0] iB,
    output [31:0] oProd
);

    //==========================================================================
    // Desempacota operandos
    //==========================================================================

    wire        A_s = iA[31];
    wire [7:0]  A_e = iA[30:23];
    wire [23:0] A_f = {1'b1, iA[22:0]};

    wire        B_s = iB[31];
    wire [7:0]  B_e = iB[30:23];
    wire [23:0] B_f = {1'b1, iB[22:0]};

    //==========================================================================
    // Sinal
    //==========================================================================

    wire prod_s = A_s ^ B_s;

    //==========================================================================
    // Multiplicação das mantissas
    //==========================================================================

    wire [47:0] prod_frac;

    assign prod_frac = A_f * B_f;

    //==========================================================================
    // Soma dos expoentes
    //==========================================================================

    wire [8:0] exp_sum;

    assign exp_sum = A_e + B_e;

    //==========================================================================
    // Normalização
    //==========================================================================

    wire normalize;

    assign normalize = prod_frac[47];

    // Mantissa sem arredondamento

    wire [22:0] mantissa;

    assign mantissa =
        normalize ?
            prod_frac[46:24] :
            prod_frac[45:23];

    //==========================================================================
    // Guard / Round / Sticky
    //==========================================================================

    wire guard;
    wire round_bit;
    wire sticky;

    assign guard =
        normalize ?
            prod_frac[23] :
            prod_frac[22];

    assign round_bit =
        normalize ?
            prod_frac[22] :
            prod_frac[21];

    assign sticky =
        normalize ?
            |prod_frac[21:0] :
            |prod_frac[20:0];

    //==========================================================================
    // Round to nearest even
    //==========================================================================

    wire round_up;

    assign round_up =
        guard &&
        (round_bit || sticky || mantissa[0]);

    wire [23:0] mantissa_round;

    assign mantissa_round = {1'b0, mantissa} + round_up;

    //==========================================================================
    // Ajuste caso o arredondamento gere carry
    //==========================================================================

    wire carry;

    assign carry = mantissa_round[23];

    wire [22:0] final_frac;

    assign final_frac =
        carry ?
            mantissa_round[23:1] :
            mantissa_round[22:0];

    //==========================================================================
    // Expoente final
    //==========================================================================

    wire [8:0] final_exp;

    assign final_exp =
        exp_sum
        - 9'd127
        + normalize
        + carry;

    //==========================================================================
    // Underflow
    //==========================================================================

    wire underflow;

    assign underflow = (final_exp == 0);

    //==========================================================================
    // Resultado
    //==========================================================================

    assign oProd =
        (A_e == 0 || B_e == 0 || underflow) ?
            32'b0 :
            {prod_s, final_exp[7:0], final_frac};

endmodule