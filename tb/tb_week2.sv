`timescale 1ns/1ps

module tb_week2;
    reg [7:0] byte_in;
    wire [7:0] byte_out;
    reg [127:0] state_in;
    wire [127:0] sub_bytes_out;
    wire [127:0] shift_rows_out;
    reg [7:0] sbox_ref [0:255];
    integer vector;

    minisoc_aes_sbox sbox_dut (
        .data_in(byte_in),
        .data_out(byte_out)
    );

    minisoc_aes_sub_bytes sub_bytes_dut (
        .state_in(state_in),
        .state_out(sub_bytes_out)
    );

    minisoc_aes_shift_rows shift_rows_dut (
        .state_in(sub_bytes_out),
        .state_out(shift_rows_out)
    );

    initial begin
        $readmemh("tb/aes_sbox_ref.hex", sbox_ref);

        for (vector = 0; vector < 256; vector = vector + 1) begin
            byte_in = vector[7:0];
            #1 if (byte_out !== sbox_ref[vector]) begin
                $display("FAIL: S-box[%02h] = %02h, expected %02h",
                         byte_in, byte_out, sbox_ref[vector]);
                $fatal(1);
            end
        end
        $display("PASS: all 256 S-box entries");

        state_in = 128'h193de3bea0f4e22b9ac68d2ae9f84808;
        #1 begin
            if (sub_bytes_out !== 128'hd42711aee0bf98f1b8b45de51e415230) begin
                $display("FAIL: round 1 SubBytes = %032h", sub_bytes_out);
                $fatal(1);
            end
            if (shift_rows_out !== 128'hd4bf5d30e0b452aeb84111f11e2798e5) begin
                $display("FAIL: round 1 ShiftRows = %032h", shift_rows_out);
                $fatal(1);
            end
        end

        state_in = 128'h549932d1f08557681093ed9cbe2c974e;
        #1 begin
            if (sub_bytes_out !== 128'h20ee233e8c975b45cadc55deae71882f) begin
                $display("FAIL: round 10 SubBytes = %032h", sub_bytes_out);
                $fatal(1);
            end
            if (shift_rows_out !== 128'h2097552f8cdc883eca712345aeee5bde) begin
                $display("FAIL: round 10 ShiftRows = %032h", shift_rows_out);
                $fatal(1);
            end
        end

        $display("PASS: FIPS-197 Appendix B rounds 1 and 10");
        $finish;
    end
endmodule
