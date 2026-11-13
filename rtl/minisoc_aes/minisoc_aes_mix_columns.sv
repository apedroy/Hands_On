module minisoc_aes_mix_columns (
    input wire [127:0] state_in,
    output wire [127:0] state_out
);
    function [7:0] multiply_by_2;
        input [7:0] value;
        begin
            multiply_by_2 = {value[6:0], 1'b0} ^
                            (value[7] ? 8'h1b : 8'h00);
        end
    endfunction

    function [7:0] multiply_by_3;
        input [7:0] value;
        begin
            multiply_by_3 = multiply_by_2(value) ^ value;
        end
    endfunction

    function [31:0] mix_column;
        input [31:0] column;
        reg [7:0] a0;
        reg [7:0] a1;
        reg [7:0] a2;
        reg [7:0] a3;
        begin
            {a0, a1, a2, a3} = column;
            mix_column = {
                multiply_by_2(a0) ^ multiply_by_3(a1) ^ a2 ^ a3,
                a0 ^ multiply_by_2(a1) ^ multiply_by_3(a2) ^ a3,
                a0 ^ a1 ^ multiply_by_2(a2) ^ multiply_by_3(a3),
                multiply_by_3(a0) ^ a1 ^ a2 ^ multiply_by_2(a3)
            };
        end
    endfunction

    assign state_out[127:96] = mix_column(state_in[127:96]);
    assign state_out[95:64] = mix_column(state_in[95:64]);
    assign state_out[63:32] = mix_column(state_in[63:32]);
    assign state_out[31:0] = mix_column(state_in[31:0]);
endmodule
