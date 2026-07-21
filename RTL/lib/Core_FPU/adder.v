module adder(a, b, op, results, compare);

    input op;
    input [31:0] a, b; // [31] Sign, [30:23] Exponent, [22:0] Mantissa
    output reg [31:0] results;
    output reg [1:0] compare;

    reg [7:0] a_exp, b_exp, r_exp, max_exp;
    reg [31:0] a_m, b_m, r_m;
    reg [31:0] r_m_norm;
    reg [7:0] exp_diff;
    reg [31:0] mask;
    reg sticky;
    reg guard_bit, round_bit, sticky_bit, lsb_bit;
    integer i;
    reg state;
    reg sign;

    always @(*) begin
        // 1. Decompor e Expandir
        // Adicionamos 3 bits na base para Guard, Round, Sticky
        // Formato interno: [26] bit oculto '1', [25:3] fração, [2:0] G, R, S
        a_exp = a[30:23];
        a_m = {5'b0, 1'b1, a[22:0], 3'b000}; 
        b_exp = b[30:23];
        b_m = {5'b0, 1'b1, b[22:0], 3'b000};

        // 2. Ordenar e Alinhar
        if (a_exp > b_exp) begin
            compare = 0;
            exp_diff = a_exp - b_exp;
            max_exp = a_exp;
            // Cria uma máscara para capturar todos os bits que serão descartados
            mask = (exp_diff >= 32) ? 32'hFFFFFFFF : ((32'b1 << exp_diff) - 1);
            sticky = |(b_m & mask); // OR lógico de todos os bits descartados
            b_m = (b_m >> exp_diff);
            b_m[0] = b_m[0] | sticky; // Preserva o sticky no bit menos significativo
        end
        else if (a_exp < b_exp) begin
            compare = 1;
            exp_diff = b_exp - a_exp;
            max_exp = b_exp;
            mask = (exp_diff >= 32) ? 32'hFFFFFFFF : ((32'b1 << exp_diff) - 1);
            sticky = |(a_m & mask);
            a_m = (a_m >> exp_diff);
            a_m[0] = a_m[0] | sticky;
        end
        else begin
            max_exp = a_exp;
            exp_diff = 0;
            if (a_m > b_m) compare = 0;
            else if (a_m < b_m) compare = 1;
            else compare = 2;
        end

        // 3. Adição / Subtração
        if ((a[31] == b[31] && !op) || (a[31] != b[31] && op)) begin
            sign = a[31];
            r_m = a_m + b_m;
        end
        else begin
            if (compare == 0 || (compare == 2 && a[31] == 0)) begin // |a| >= |b|
                r_m = a_m - b_m;
                sign = op ? 1'b0 : a[31];
            end
            else begin // |a| < |b|
                r_m = b_m - a_m;
                sign = op ? (b[31] ? 1'b0 : 1'b1) : b[31];
            end
        end

        // 4. Normalização
        if (r_m == 0) begin
            r_exp = 0;
            r_m_norm = 0;
            sign = 0;
        end
        else begin
            state = 1;
            i = 31;
            // Encontra a posição do bit '1' mais significativo (Leading Zero Counter)
            while (state == 1 && i > 0) begin
                if (r_m[i] == 1) state = 0;
                else i = i - 1;
            end

            // Ajusta a mantissa para que o bit oculto fique sempre no bit 26
            if (i > 26) begin
                // Houve overflow na adição, precisamos deslocar para a direita
                mask = (32'b1 << (i - 26)) - 1;
                sticky = |(r_m & mask);
                r_m_norm = r_m >> (i - 26);
                r_m_norm[0] = r_m_norm[0] | sticky; // Atualiza o sticky
            end
            else if (i < 26) begin
                // Precisamos deslocar para a esquerda
                r_m_norm = r_m << (26 - i);
            end
            else begin
                r_m_norm = r_m;
            end

            r_exp = max_exp + (i - 26);

            // 5. Arredondamento (Round to Nearest, Ties to Even)
            guard_bit  = r_m_norm[2];
            round_bit  = r_m_norm[1];
            sticky_bit = r_m_norm[0];
            lsb_bit    = r_m_norm[3]; // Bit menos significativo da fração real

            // Condição para arredondar para cima
            if (guard_bit && (round_bit || sticky_bit || lsb_bit)) begin
                r_m_norm = r_m_norm + 4'b1000; // Soma '1' na posição do LSB (bit 3)
                
                // Verifica se o arredondamento causou um novo overflow (ex: 1.111... -> 10.000...)
                if (r_m_norm[27] == 1) begin
                    r_m_norm = r_m_norm >> 1;
                    r_exp = r_exp + 1;
                end
            end
        end

        // 6. Composição Final
        results[31] = sign;
        results[30:23] = r_exp;
        results[22:0] = r_m_norm[25:3]; // Descartamos o bit oculto [26] e os bits GRS [2:0]
    end

endmodule