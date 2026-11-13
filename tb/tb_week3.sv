`timescale 1ns/1ps

module tb_week3;
    reg [7:0] byte_in;
    wire [7:0] inverse_byte_out;
    reg [7:0] sbox_ref [0:255];
    reg [7:0] inverse_sbox_ref [0:255];
    reg [127:0] state_in;
    reg [127:0] round_key;
    wire [127:0] add_round_key_out;
    wire [127:0] inverse_sub_bytes_out;
    wire [127:0] inverse_shift_rows_out;
    wire [127:0] mix_columns_out;
    wire [127:0] inverse_mix_columns_out;
    integer vector;

    minisoc_aes_inv_sbox inverse_sbox_dut (
        .data_in(byte_in),
        .data_out(inverse_byte_out)
    );

    minisoc_aes_add_round_key add_round_key_dut (
        .state_in(state_in),
        .round_key(round_key),
        .state_out(add_round_key_out)
    );

    minisoc_aes_inv_sub_bytes inverse_sub_bytes_dut (
        .state_in(state_in),
        .state_out(inverse_sub_bytes_out)
    );

    minisoc_aes_inv_shift_rows inverse_shift_rows_dut (
        .state_in(state_in),
        .state_out(inverse_shift_rows_out)
    );

    minisoc_aes_mix_columns mix_columns_dut (
        .state_in(state_in),
        .state_out(mix_columns_out)
    );

    minisoc_aes_inv_mix_columns inverse_mix_columns_dut (
        .state_in(state_in),
        .state_out(inverse_mix_columns_out)
    );

    initial begin
        $readmemh("tb/aes_sbox_ref.hex", sbox_ref);
        for (vector = 0; vector < 256; vector = vector + 1)
            inverse_sbox_ref[sbox_ref[vector]] = vector[7:0];

        for (vector = 0; vector < 256; vector = vector + 1) begin
            byte_in = vector[7:0];
            #1 if (inverse_byte_out !== inverse_sbox_ref[vector]) begin
                $display("FAIL: inverse S-box[%02h] = %02h, expected %02h",
                         byte_in, inverse_byte_out, inverse_sbox_ref[vector]);
                $fatal(1);
            end
        end
        $display("PASS: all 256 inverse S-box entries");

        state_in = 128'h6353e08c0960e104cd70b751bacad0e7;
        #1 if (mix_columns_out !== 128'h5f72641557f5bc92f7be3b291db9f91a) begin
            $display("FAIL: MixColumns = %032h", mix_columns_out);
            $fatal(1);
        end

        state_in = 128'h5f72641557f5bc92f7be3b291db9f91a;
        #1 if (inverse_mix_columns_out !== 128'h6353e08c0960e104cd70b751bacad0e7) begin
            $display("FAIL: InvMixColumns = %032h", inverse_mix_columns_out);
            $fatal(1);
        end
        $display("PASS: FIPS-197 Appendix B MixColumns and inverse");

        state_in = 128'h5f72641557f5bc92f7be3b291db9f91a;
        round_key = 128'hd6aa74fdd2af72fadaa678f1d6ab76fe;
        #1 if (add_round_key_out !== 128'h89d810e8855ace682d1843d8cb128fe4) begin
            $display("FAIL: AddRoundKey = %032h", add_round_key_out);
            $fatal(1);
        end
        $display("PASS: FIPS-197 Appendix B AddRoundKey");

        state_in = 128'hd4bf5d30e0b452aeb84111f11e2798e5;
        #1 begin
            if (inverse_shift_rows_out !== 128'hd42711aee0bf98f1b8b45de51e415230) begin
                $display("FAIL: InvShiftRows = %032h", inverse_shift_rows_out);
                $fatal(1);
            end
        end

        state_in = 128'hd42711aee0bf98f1b8b45de51e415230;
        #1 if (inverse_sub_bytes_out !== 128'h193de3bea0f4e22b9ac68d2ae9f84808) begin
            $display("FAIL: InvSubBytes = %032h", inverse_sub_bytes_out);
            $fatal(1);
        end
        $display("PASS: FIPS-197 Appendix B inverse SubBytes/ShiftRows");

        state_in = 128'h7ad5fda789ef4e272bca100b3d9ff59f;
        #1 if (inverse_shift_rows_out !== 128'h7a9f102789d5f50b2beffd9f3dca4ea7) begin
            $display("FAIL: Appendix C.1 InvShiftRows = %032h", inverse_shift_rows_out);
            $fatal(1);
        end

        state_in = 128'h7a9f102789d5f50b2beffd9f3dca4ea7;
        #1 if (inverse_sub_bytes_out !== 128'hbd6e7c3df2b5779e0b61216e8b10b689) begin
            $display("FAIL: Appendix C.1 InvSubBytes = %032h", inverse_sub_bytes_out);
            $fatal(1);
        end

        state_in = 128'hbd6e7c3df2b5779e0b61216e8b10b689;
        round_key = 128'h549932d1f08557681093ed9cbe2c974e;
        #1 if (add_round_key_out !== 128'he9f74eec023020f61bf2ccf2353c21c7) begin
            $display("FAIL: Appendix C.1 AddRoundKey = %032h", add_round_key_out);
            $fatal(1);
        end

        state_in = 128'he9f74eec023020f61bf2ccf2353c21c7;
        #1 if (inverse_mix_columns_out !== 128'h54d990a16ba09ab596bbf40ea111702f) begin
            $display("FAIL: Appendix C.1 InvMixColumns = %032h", inverse_mix_columns_out);
            $fatal(1);
        end
        $display("PASS: Appendix C.1 inverse round transforms");
        $finish;
    end
endmodule
