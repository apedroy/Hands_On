module minisoc_aes_inv_mix_columns (
    input wire [127:0] state_in,
    output wire [127:0] state_out
);
    function [7:0] multiply_gf;
        input [7:0] value;
        input [7:0] coefficient;
        reg [7:0] multiplicand;
        reg [7:0] multiplier;
        integer bit_index;
        begin
            multiply_gf = 8'h00;
            multiplicand = value;
            multiplier = coefficient;
            for (bit_index = 0; bit_index < 8; bit_index = bit_index + 1) begin
                if (multiplier[0])
                    multiply_gf = multiply_gf ^ multiplicand;
                multiplicand = {multiplicand[6:0], 1'b0} ^
                               (multiplicand[7] ? 8'h1b : 8'h00);
                multiplier = multiplier >> 1;
            end
        end
    endfunction

    function [31:0] inverse_mix_column;
        input [31:0] column;
        reg [7:0] a0;
        reg [7:0] a1;
        reg [7:0] a2;
        reg [7:0] a3;
        begin
            {a0, a1, a2, a3} = column;
            inverse_mix_column = {
                multiply_gf(a0, 8'h0e) ^ multiply_gf(a1, 8'h0b) ^
                    multiply_gf(a2, 8'h0d) ^ multiply_gf(a3, 8'h09),
                multiply_gf(a0, 8'h09) ^ multiply_gf(a1, 8'h0e) ^
                    multiply_gf(a2, 8'h0b) ^ multiply_gf(a3, 8'h0d),
                multiply_gf(a0, 8'h0d) ^ multiply_gf(a1, 8'h09) ^
                    multiply_gf(a2, 8'h0e) ^ multiply_gf(a3, 8'h0b),
                multiply_gf(a0, 8'h0b) ^ multiply_gf(a1, 8'h0d) ^
                    multiply_gf(a2, 8'h09) ^ multiply_gf(a3, 8'h0e)
            };
        end
    endfunction

    assign state_out[127:96] = inverse_mix_column(state_in[127:96]);
    assign state_out[95:64] = inverse_mix_column(state_in[95:64]);
    assign state_out[63:32] = inverse_mix_column(state_in[63:32]);
    assign state_out[31:0] = inverse_mix_column(state_in[31:0]);
endmodule
