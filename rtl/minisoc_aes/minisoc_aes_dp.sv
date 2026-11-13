module minisoc_aes_dp (
    input wire clk,
    input wire rst_n,
    input wire start,
    input wire decrypt,
    input wire [127:0] key,
    input wire [127:0] block_in,
    output reg [127:0] block_out,
    output wire busy,
    output reg done
);
    typedef enum logic [2:0] {
        IDLE, KEY_START, KEY_WAIT, INITIAL_KEY, ROUND
    } control_state_t;

    control_state_t control_state;
    reg [127:0] state_reg;
    reg [127:0] key_reg;
    reg decrypt_reg;
    reg [3:0] round_index;
    wire [127:0] round_key;
    wire keys_done;
    wire [127:0] sub_bytes_out;
    wire [127:0] shift_rows_out;
    wire [127:0] mix_columns_out;
    wire [127:0] inv_shift_rows_out;
    wire [127:0] inv_sub_bytes_out;
    wire [127:0] inv_mix_columns_out;
    wire [127:0] key_operand;
    wire [127:0] add_round_key_out;
    wire [127:0] round_result;
    wire final_round;

    assign busy = (control_state != IDLE);
    assign final_round = decrypt_reg ? (round_index == 4'd0) : (round_index == 4'd10);

    minisoc_aes_key_exp key_exp (
        .clk(clk),
        .rst_n(rst_n),
        .start(control_state == KEY_START),
        .key(key_reg),
        .round_index(round_index),
        .round_key(round_key),
        .busy(),
        .done(keys_done)
    );

    minisoc_aes_sub_bytes sub_bytes (.state_in(state_reg), .state_out(sub_bytes_out));
    minisoc_aes_shift_rows shift_rows (.state_in(sub_bytes_out), .state_out(shift_rows_out));
    minisoc_aes_mix_columns mix_columns (.state_in(shift_rows_out), .state_out(mix_columns_out));

    minisoc_aes_inv_shift_rows inv_shift_rows (.state_in(state_reg), .state_out(inv_shift_rows_out));
    minisoc_aes_inv_sub_bytes inv_sub_bytes (.state_in(inv_shift_rows_out), .state_out(inv_sub_bytes_out));

    // Na cifra a mistura vem antes do XOR; na inversa, depois do XOR.
    assign key_operand = (control_state == INITIAL_KEY) ? state_reg :
                         decrypt_reg ? inv_sub_bytes_out :
                         final_round ? shift_rows_out : mix_columns_out;
    minisoc_aes_add_round_key add_round_key (
        .state_in(key_operand),
        .round_key(round_key),
        .state_out(add_round_key_out)
    );
    minisoc_aes_inv_mix_columns inv_mix_columns (
        .state_in(add_round_key_out),
        .state_out(inv_mix_columns_out)
    );
    assign round_result = (decrypt_reg && !final_round) ?
                          inv_mix_columns_out : add_round_key_out;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            control_state <= IDLE;
            state_reg <= 128'h0;
            key_reg <= 128'h0;
            decrypt_reg <= 1'b0;
            round_index <= 4'd0;
            block_out <= 128'h0;
            done <= 1'b0;
        end else begin
            done <= 1'b0;
            case (control_state)
                IDLE: begin
                    if (start) begin
                        state_reg <= block_in;
                        key_reg <= key;
                        decrypt_reg <= decrypt;
                        round_index <= decrypt ? 4'd10 : 4'd0;
                        control_state <= KEY_START;
                    end
                end
                KEY_START: control_state <= KEY_WAIT;
                KEY_WAIT: begin
                    if (keys_done)
                        control_state <= INITIAL_KEY;
                end
                INITIAL_KEY: begin
                    state_reg <= add_round_key_out;
                    round_index <= decrypt_reg ? 4'd9 : 4'd1;
                    control_state <= ROUND;
                end
                ROUND: begin
                    state_reg <= round_result;
                    if (final_round) begin
                        block_out <= round_result;
                        done <= 1'b1;
                        control_state <= IDLE;
                    end else begin
                        round_index <= decrypt_reg ? round_index - 4'd1 :
                                                     round_index + 4'd1;
                    end
                end
                default: begin
                    // synthesis translate_off
                    $error("Invalid AES datapath control state");
                    // synthesis translate_on
                    control_state <= IDLE;
                end
            endcase
        end
    end
endmodule
