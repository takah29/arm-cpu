module FlopenrTestbench;
    parameter DELAY = 10;

    `include "common_clk.h"

    logic reset;
    logic en;
    logic [3:0] d;
    logic [3:0] q, qexpected;
    logic [31:0] vectornum, errors;
    logic [9:0] testvectors[0:8];

    Flopenr #(4) dut(clk, reset, en, d, q);

    initial begin
        errors = 0;
        reset = 1;
        #DELAY;
        reset = 0;
        #DELAY;

        $readmemb("test_flopenr.tv", testvectors);
        vectornum = 0;
    end

    always @(negedge clk) begin
        #DELAY
        {reset, en, d, qexpected} = testvectors[vectornum];
        #HALF_CYCLE

        if (q !== qexpected) begin
            $display("Error: input = %b", d);
            $display(" outputs = %b (%b expected)", q, qexpected);
            errors = errors + 1;
        end

        vectornum = vectornum + 1;
        // 終了判定
        if (testvectors[vectornum] === 10'bx) begin
            $display("%d test completed with %d errors", vectornum, errors);
            $finish;
        end
    end
endmodule
