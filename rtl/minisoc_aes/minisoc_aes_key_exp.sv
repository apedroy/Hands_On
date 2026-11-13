module minisoc_aes_key_exp (
    input wire clk,
    input wire rst_n,
    input wire start,
    input wire [127:0] key,
    input wire [3:0] round_index,
    output wire [127:0] round_key,
    output reg busy,
    output reg done
);
    reg [127:0] round_keys [0:10];
    reg [127:0] previous_key;
    reg [3:0] next_round;
    reg [7:0] rcon;
    wire [31:0] sub_word;
    wire [31:0] word_0;
    wire [31:0] word_1;
    wire [31:0] word_2;
    wire [31:0] word_3;
    integer reset_index;

    // RotWord gira o ultimo word um byte; SubWord aplica quatro S-boxes.
    minisoc_aes_sbox sbox_0 (.data_in(previous_key[23:16]), .data_out(sub_word[31:24]));
    minisoc_aes_sbox sbox_1 (.data_in(previous_key[15:8]), .data_out(sub_word[23:16]));
    minisoc_aes_sbox sbox_2 (.data_in(previous_key[7:0]), .data_out(sub_word[15:8]));
    minisoc_aes_sbox sbox_3 (.data_in(previous_key[31:24]), .data_out(sub_word[7:0]));

    assign word_0 = previous_key[127:96] ^ sub_word ^ {rcon, 24'h000000};
    assign word_1 = previous_key[95:64] ^ word_0;
    assign word_2 = previous_key[63:32] ^ word_1;
    assign word_3 = previous_key[31:0] ^ word_2;
    assign round_key = round_keys[round_index];

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            previous_key <= 128'h0;
            next_round <= 4'd1;
            rcon <= 8'h01;
            busy <= 1'b0;
            done <= 1'b0;
            for (reset_index = 0; reset_index < 11; reset_index = reset_index + 1)
                round_keys[reset_index] <= 128'h0;
        end else begin
            done <= 1'b0;
            if (busy) begin
                round_keys[next_round] <= {word_0, word_1, word_2, word_3};
                previous_key <= {word_0, word_1, word_2, word_3};
                rcon <= {rcon[6:0], 1'b0} ^ (rcon[7] ? 8'h1b : 8'h00);
                if (next_round == 4'd10) begin
                    busy <= 1'b0;
                    done <= 1'b1;
                end else begin
                    next_round <= next_round + 4'd1;
                end
            end else if (start) begin
                round_keys[0] <= key;
                previous_key <= key;
                next_round <= 4'd1;
                rcon <= 8'h01;
                busy <= 1'b1;
            end
        end
    end
endmodule
