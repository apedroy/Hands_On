`timescale 1ns/1ps

module tb_week1;
    reg a;
    reg b;
    wire y;
    integer vector;

    week1_smoke dut (
        .a(a),
        .b(b),
        .y(y)
    );

    initial begin
        for (vector = 0; vector < 4; vector = vector + 1) begin
            {a, b} = vector[1:0];
            #1;
            if (y !== (a ^ b)) begin
                $display("FAIL: a=%b b=%b y=%b", a, b, y);
                $fatal(1);
            end
        end

        $display("PASS: all 4 smoke-test vectors");
        $finish;
    end
endmodule