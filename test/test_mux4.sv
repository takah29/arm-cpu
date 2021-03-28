module Mux4Testbench();
    logic clk, reset;
    logic [3:0] d0, d1, d2, d3;
    logic [1:0] s;
    logic [3:0] y, yexpected;
    logic [31:0] vectornum, errors;
    logic [21:0] testvectors[0:3];

    Mux4 #(4) dut(d0, d1, d2, d3, s, y);

    always begin
        clk = 1;
        #5;
        clk = 0;
        #5;
    end

    initial begin
        $readmemb("test_mux4.tv", testvectors);
        vectornum = 0;
        errors = 0;
        reset = 1;
        #27;
        reset = 0;
    end

    always @(posedge clk) begin
        #1;
        {d0, d1, d2, d3, s, yexpected} = testvectors[vectornum];
    end

    always @(negedge clk) begin
        if (~reset) begin
            if (y !== yexpected) begin
                $display("Error: input = (%b, %b, %d, %d, %b)", d0, d1, d2, d3, s);
                $display(" outputs = %b (%b expected)", y, yexpected);
                errors = errors + 1;
            end
            vectornum = vectornum + 1;
            if (testvectors[vectornum] === 22'bx) begin
                $display("%d test completed with %d errors", vectornum, errors);
                $finish;
            end
        end
    end
endmodule
