module flopr_testbench;
    parameter N = 4;
    parameter DELAY = 10;

    `include "common_clk.h"

    logic reset;
    logic [N - 1:0] d;
    logic [N - 1:0] q, qexpected;
    logic [31:0] vectornum, errors;
    logic [8:0] testvectors[0:5];

    flopr #(N) dut(clk, reset, d, q);

    initial begin
        errors = 0;
        reset = 1;
        #DELAY;
        reset = 0;
        #DELAY;

        $readmemb("test_flopr.tv", testvectors);
        vectornum = 0;
    end

    always @(negedge clk) begin
        #DELAY
        {reset, d, qexpected} = testvectors[vectornum];
        #HALF_CYCLE

        if (q !== qexpected) begin
            $display("Error: input = %b", d);
            $display(" outputs = %b (%b expected)", q, qexpected);
            errors = errors + 1;
        end

        vectornum = vectornum + 1;
        // 終了判定
        if (testvectors[vectornum] === 9'bx) begin
            $display("%d test completed with %d errors", vectornum, errors);
            $finish;
        end
    end
endmodule
