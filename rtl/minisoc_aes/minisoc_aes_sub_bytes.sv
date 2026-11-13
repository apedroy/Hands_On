module minisoc_aes_sub_bytes (
    input wire [127:0] state_in,
    output wire [127:0] state_out
);
    // O estado do AES tem 16 bytes; cada S-box substitui um byte
    // independentemente e devolve o resultado para a mesma posicao.
    minisoc_aes_sbox sbox_byte_0 (
        .data_in(state_in[127:120]),
        .data_out(state_out[127:120])
    );
    minisoc_aes_sbox sbox_byte_1 (
        .data_in(state_in[119:112]),
        .data_out(state_out[119:112])
    );
    minisoc_aes_sbox sbox_byte_2 (
        .data_in(state_in[111:104]),
        .data_out(state_out[111:104])
    );
    minisoc_aes_sbox sbox_byte_3 (
        .data_in(state_in[103:96]),
        .data_out(state_out[103:96])
    );
    minisoc_aes_sbox sbox_byte_4 (
        .data_in(state_in[95:88]),
        .data_out(state_out[95:88])
    );
    minisoc_aes_sbox sbox_byte_5 (
        .data_in(state_in[87:80]),
        .data_out(state_out[87:80])
    );
    minisoc_aes_sbox sbox_byte_6 (
        .data_in(state_in[79:72]),
        .data_out(state_out[79:72])
    );
    minisoc_aes_sbox sbox_byte_7 (
        .data_in(state_in[71:64]),
        .data_out(state_out[71:64])
    );
    minisoc_aes_sbox sbox_byte_8 (
        .data_in(state_in[63:56]),
        .data_out(state_out[63:56])
    );
    minisoc_aes_sbox sbox_byte_9 (
        .data_in(state_in[55:48]),
        .data_out(state_out[55:48])
    );
    minisoc_aes_sbox sbox_byte_10 (
        .data_in(state_in[47:40]),
        .data_out(state_out[47:40])
    );
    minisoc_aes_sbox sbox_byte_11 (
        .data_in(state_in[39:32]),
        .data_out(state_out[39:32])
    );
    minisoc_aes_sbox sbox_byte_12 (
        .data_in(state_in[31:24]),
        .data_out(state_out[31:24])
    );
    minisoc_aes_sbox sbox_byte_13 (
        .data_in(state_in[23:16]),
        .data_out(state_out[23:16])
    );
    minisoc_aes_sbox sbox_byte_14 (
        .data_in(state_in[15:8]),
        .data_out(state_out[15:8])
    );
    minisoc_aes_sbox sbox_byte_15 (
        .data_in(state_in[7:0]),
        .data_out(state_out[7:0])
    );
endmodule