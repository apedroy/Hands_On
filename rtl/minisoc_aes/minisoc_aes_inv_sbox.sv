module minisoc_aes_inv_sbox (
    input wire [7:0] data_in,
    output wire [7:0] data_out
);
    reg [127:0] lookup_row;

    always @* begin
        case (data_in[7:4])
            4'h0: lookup_row = 128'h52096ad53036a538bf40a39e81f3d7fb;
            4'h1: lookup_row = 128'h7ce339829b2fff87348e4344c4dee9cb;
            4'h2: lookup_row = 128'h547b9432a6c2233dee4c950b42fac34e;
            4'h3: lookup_row = 128'h082ea16628d924b2765ba2496d8bd125;
            4'h4: lookup_row = 128'h72f8f66486689816d4a45ccc5d65b692;
            4'h5: lookup_row = 128'h6c704850fdedb9da5e154657a78d9d84;
            4'h6: lookup_row = 128'h90d8ab008cbcd30af7e45805b8b34506;
            4'h7: lookup_row = 128'hd02c1e8fca3f0f02c1afbd0301138a6b;
            4'h8: lookup_row = 128'h3a9111414f67dcea97f2cfcef0b4e673;
            4'h9: lookup_row = 128'h96ac7422e7ad3585e2f937e81c75df6e;
            4'ha: lookup_row = 128'h47f11a711d29c5896fb7620eaa18be1b;
            4'hb: lookup_row = 128'hfc563e4bc6d279209adbc0fe78cd5af4;
            4'hc: lookup_row = 128'h1fdda8338807c731b11210592780ec5f;
            4'hd: lookup_row = 128'h60517fa919b54a0d2de57a9f93c99cef;
            4'he: lookup_row = 128'ha0e03b4dae2af5b0c8ebbb3c83539961;
            4'hf: lookup_row = 128'h172b047eba77d626e169146355210c7d;
            default: lookup_row = 128'h0;
        endcase
    end

    assign data_out = lookup_row[127 - 8*data_in[3:0] -: 8];
endmodule
