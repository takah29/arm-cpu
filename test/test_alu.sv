module AluTestbench;
    parameter DELAY = 10;
    parameter N = 32;

    logic [N - 1:0] a, b;
    logic [1:0] alu_ctl;
    logic [N - 1:0] result, result_expected;

    Alu #(N) dut(.a, .b, .alu_ctl, .result);

    task assert_;
        assert (result === result_expected) else $error("result = %d, %d expected", result, result_expected);
    endtask

    initial begin
        // ADD
        alu_ctl = 2'b00;
        a = 32'd1000; b = 32'd1000; result_expected = 32'd2000; #DELAY
        assert_;
        a = 0; b = -1; result_expected = 2**32 - 1; #DELAY
        assert_;
        a = 2**32 - 1; b = 1; result_expected = 0; #DELAY

        // SUB
        alu_ctl = 2'b01;
        a = 1000; b = 1000; result_expected = 0; #DELAY
        assert_;
        a = 0; b = 1; result_expected = 2**32 - 1; #DELAY
        assert_;
        a = 2**32 - 1; b = -1; result_expected = 0; #DELAY
        assert_;

        // LMULT
        alu_ctl = 2'b10;
        a = 32'hf0f0; b = 32'h0f0f; result_expected = 32'h0000; #DELAY
        assert_;
        a = 32'hffff; b = 32'hf000; result_expected = 32'hf000; #DELAY
        assert_;

        // LSUM
        alu_ctl = 2'b11;
        a = 32'hf0f0; b = 32'h0f0f; result_expected = 32'hffff; #DELAY
        assert_;
        a = 32'h000f; b = 32'hf000; result_expected = 32'hf00f; #DELAY
        assert_;

        $display("test completed");
        $finish;
    end
endmodule
