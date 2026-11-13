`timescale 1ns/1ps

module tb_week4;
    reg clk = 1'b0;
    reg rst_n = 1'b0;
    reg start = 1'b0;
    reg decrypt = 1'b0;
    reg [127:0] key = 128'h0;
    reg [127:0] block_in = 128'h0;
    wire [127:0] block_out;
    wire busy;
    wire done;
    reg key_start = 1'b0;
    reg [127:0] expansion_key = 128'h0;
    reg [3:0] key_index = 4'd0;
    wire [127:0] expanded_key;
    wire key_busy;
    wire key_done;
    reg [127:0] expected_keys [0:10];
    integer index;
    integer cycles;

    always #5 clk = ~clk;

    minisoc_aes_dp dut (
        .clk(clk), .rst_n(rst_n), .start(start), .decrypt(decrypt),
        .key(key), .block_in(block_in), .block_out(block_out),
        .busy(busy), .done(done)
    );

    minisoc_aes_key_exp key_dut (
        .clk(clk), .rst_n(rst_n), .start(key_start), .key(expansion_key),
        .round_index(key_index), .round_key(expanded_key),
        .busy(key_busy), .done(key_done)
    );

    task automatic check_block;
        input reg inverse;
        input reg [127:0] input_key;
        input reg [127:0] input_block;
        input reg [127:0] expected_block;
        reg [127:0] previous_output;
        integer elapsed;
        begin
            @(negedge clk);
            if (busy !== 1'b0 || done !== 1'b0)
                $fatal(1, "Datapath not idle before START");
            previous_output = block_out;
            key = input_key;
            block_in = input_block;
            decrypt = inverse;
            start = 1'b1;
            @(negedge clk);
            start = 1'b0;
            if (busy !== 1'b1 || done !== 1'b0)
                $fatal(1, "START not accepted");

            // As entradas externas podem mudar depois da captura.
            key = ~input_key;
            block_in = ~input_block;
            decrypt = ~inverse;
            elapsed = 0;
            while (done !== 1'b1 && elapsed < 30) begin
                // Comandos durante expansao e rodadas nao interrompem o bloco.
                start = (elapsed == 3 || elapsed == 16);
                @(negedge clk);
                elapsed = elapsed + 1;
                if (done !== 1'b1) begin
                    if (busy !== 1'b1 || block_out !== previous_output)
                        $fatal(1, "Busy/output changed before completion");
                end
            end
            start = 1'b0;
            if (done !== 1'b1 || busy !== 1'b0 || elapsed != 23)
                $fatal(1, "Invalid completion/latency: cycles=%0d busy=%b done=%b",
                       elapsed, busy, done);
            if (block_out !== expected_block)
                $fatal(1, "AES decrypt=%b got=%032h expected=%032h",
                       inverse, block_out, expected_block);
            @(negedge clk);
            if (done !== 1'b0 || busy !== 1'b0 || block_out !== expected_block)
                $fatal(1, "DONE must pulse once and output must remain stable");
        end
    endtask

    task automatic abort_block;
        input integer wait_cycles;
        begin
            @(negedge clk);
            start = 1'b1;
            decrypt = 1'b0;
            key = 128'h000102030405060708090a0b0c0d0e0f;
            block_in = 128'h00112233445566778899aabbccddeeff;
            @(negedge clk);
            start = 1'b0;
            repeat (wait_cycles) @(negedge clk);
            if (busy !== 1'b1)
                $fatal(1, "Expected an active operation before reset");
            rst_n = 1'b0;
            #1 if (busy !== 1'b0 || done !== 1'b0 || block_out !== 128'h0)
                $fatal(1, "Reset did not abort/clear the datapath");
            @(negedge clk);
            rst_n = 1'b1;
            repeat (25) begin
                @(negedge clk);
                if (busy !== 1'b0 || done !== 1'b0)
                    $fatal(1, "Aborted operation resumed after reset");
            end
        end
    endtask

    initial begin
        #10000 $fatal(1, "Week 4 testbench timeout");
    end

    initial begin
        // FIPS-197, Apendice A.1: chave original e dez round keys.
        expected_keys[0] = 128'h2b7e151628aed2a6abf7158809cf4f3c;
        expected_keys[1] = 128'ha0fafe1788542cb123a339392a6c7605;
        expected_keys[2] = 128'hf2c295f27a96b9435935807a7359f67f;
        expected_keys[3] = 128'h3d80477d4716fe3e1e237e446d7a883b;
        expected_keys[4] = 128'hef44a541a8525b7fb671253bdb0bad00;
        expected_keys[5] = 128'hd4d1c6f87c839d87caf2b8bc11f915bc;
        expected_keys[6] = 128'h6d88a37a110b3efddbf98641ca0093fd;
        expected_keys[7] = 128'h4e54f70e5f5fc9f384a64fb24ea6dc4f;
        expected_keys[8] = 128'head27321b58dbad2312bf5607f8d292f;
        expected_keys[9] = 128'hac7766f319fadc2128d12941575c006e;
        expected_keys[10] = 128'hd014f9a8c9ee2589e13f0cc8b6630ca6;

        repeat (2) @(negedge clk);
        rst_n = 1'b1;
        @(negedge clk);
        expansion_key = expected_keys[0];
        key_start = 1'b1;
        @(negedge clk);
        key_start = 1'b0;
        expansion_key = 128'h0;
        if (key_busy !== 1'b1 || key_done !== 1'b0)
            $fatal(1, "Key expansion START not accepted");
        cycles = 0;
        while (key_done !== 1'b1 && cycles < 12) begin
            key_start = (cycles == 3);
            @(negedge clk);
            cycles = cycles + 1;
            if (key_done !== 1'b1 && key_busy !== 1'b1)
                $fatal(1, "Key expansion became idle before DONE");
        end
        key_start = 1'b0;
        if (key_done !== 1'b1 || key_busy !== 1'b0 || cycles != 10)
            $fatal(1, "Invalid key expansion completion/latency");
        @(negedge clk);
        if (key_done !== 1'b0)
            $fatal(1, "Key expansion DONE is not a one-cycle pulse");
        for (index = 0; index < 11; index = index + 1) begin
            key_index = index[3:0];
            #1 if (expanded_key !== expected_keys[index])
                $fatal(1, "Round key %0d got=%032h expected=%032h",
                       index, expanded_key, expected_keys[index]);
        end
        $display("PASS: FIPS-197 Appendix A.1 all 11 round keys");

        check_block(1'b0, 128'h000102030405060708090a0b0c0d0e0f,
                    128'h00112233445566778899aabbccddeeff,
                    128'h69c4e0d86a7b0430d8cdb78070b4c55a);
        check_block(1'b1, 128'h000102030405060708090a0b0c0d0e0f,
                    128'h69c4e0d86a7b0430d8cdb78070b4c55a,
                    128'h00112233445566778899aabbccddeeff);
        $display("PASS: FIPS-197 Appendix C.1 encrypt and decrypt");

        check_block(1'b0, 128'h2b7e151628aed2a6abf7158809cf4f3c,
                    128'h3243f6a8885a308d313198a2e0370734,
                    128'h3925841d02dc09fbdc118597196a0b32);
        check_block(1'b1, 128'h2b7e151628aed2a6abf7158809cf4f3c,
                    128'h3925841d02dc09fbdc118597196a0b32,
                    128'h3243f6a8885a308d313198a2e0370734);
        $display("PASS: FIPS-197 Appendix B encrypt and decrypt");

        check_block(1'b0, 128'h0, 128'h0, 128'h66e94bd4ef8a2c3b884cfa59ca342b2e);
        check_block(1'b1, 128'h0, 128'h66e94bd4ef8a2c3b884cfa59ca342b2e, 128'h0);
        $display("PASS: zero key/block encrypt and decrypt");

        abort_block(3);
        check_block(1'b0, 128'h000102030405060708090a0b0c0d0e0f,
                    128'h00112233445566778899aabbccddeeff,
                    128'h69c4e0d86a7b0430d8cdb78070b4c55a);
        abort_block(16);
        check_block(1'b1, 128'h000102030405060708090a0b0c0d0e0f,
                    128'h69c4e0d86a7b0430d8cdb78070b4c55a,
                    128'h00112233445566778899aabbccddeeff);
        $display("PASS: captured inputs, busy START, DONE pulse and reset recovery");
        $display("PASS: all Week 4 tests");
        $finish;
    end
endmodule
