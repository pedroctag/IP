module fp2int(A, B);
    input  [31:0] A;
    output reg [31:0] B;

    reg sign;
    reg [7:0] e;
    reg [23:0] m;
    reg [31:0] abs_int;
    reg [7:0] shift_amt;
    
    // Variáveis auxiliares para o arredondamento
    reg [23:0] frac_mask;
    reg round_bit, sticky_bit, lsb_bit;

    always @(*) begin
        // 1. Extração dos campos
        sign = A[31];
        e    = A[30:23];
        m    = {1'b1, A[22:0]}; // Mantissa com o bit oculto

        // 2. Limites (Casos Base)
        if (e < 126) begin 
            // Valores menores que 0.5 (arredondam para 0)
            abs_int = 32'd0;
        end
        else if (e > 157) begin
            // Overflow (Valor máximo possível para um int de 32 bits)
            abs_int = 32'h7FFFFFFF;
        end
        else begin
            // 3. Alinhamento
            // Quando e = 150, a mantissa se alinha perfeitamente sem deslocamentos (150-127 = 23 bits de expoente = 23 bits de mantissa)
            if (e <= 150) begin
                shift_amt = 150 - e;
                abs_int = m >> shift_amt;

                // 4. Arredondamento
                if (shift_amt > 0) begin
                    round_bit = m[shift_amt - 1]; // O primeiro bit que "caiu" (peso de 0.5)
                    
                    // Máscara para verificar se qualquer bit APÓS o round_bit era '1'
                    frac_mask = (24'b1 << (shift_amt - 1)) - 1;
                    sticky_bit = |(m & frac_mask); 
                    
                    lsb_bit = abs_int[0]; // Bit menos significativo da parte inteira

                    // Round to Nearest, Ties to Even
                    if (round_bit && (sticky_bit || lsb_bit)) begin
                        abs_int = abs_int + 1;
                    end
                end
            end
            else begin
                // e > 150: Precisamos deslocar para a esquerda
                shift_amt = e - 150;
                abs_int = m << shift_amt;
                // Como deslocamos para a esquerda, nenhuma fração foi perdida. Arredondamento não é necessário.
            end
        end

        // 5. Aplicação do Sinal (Complemento de 2 para números negativos)
        if (sign && abs_int != 0)
            B = (~abs_int) + 32'd1;
        else
            B = abs_int;
    end

endmodule