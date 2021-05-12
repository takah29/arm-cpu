module AluTestbench;
    parameter DELAY = 10;
    parameter N = 32;

    logic [N - 1:0] a, b;
    logic [2:0] alu_ctl;
    logic carry;
    logic [N - 1:0] result, result_expected;
    logic [1:0] cv_flags;

    Alu #(N) dut(.a, .b, .alu_ctl, .carry, .result, .cv_flags);

    task assert_;
        assert (result === result_expected) else $error("result = %d, %d expected", result, result_expected);
    endtask

    initial begin
        // case carry = 0
        carry = 0;

        // ADD
        alu_ctl = 3'b000;
        a = 1000; b = 1000; result_expected = 2000; #DELAY;
        assert_;
        a = 0; b = -1; result_expected = 2**32 - 1; #DELAY;
        assert_;
        a = 2**32 - 1; b = 1; result_expected = 0; #DELAY;
        assert_;

        // SUB
        alu_ctl = 3'b001;
        a = 1000; b = 1000; result_expected = 0; #DELAY;
        assert_;
        a = 0; b = 1; result_expected = 2**32 - 1; #DELAY;
        assert_;
        a = 2**32 - 1; b = -1; result_expected = 0; #DELAY;
        assert_;

        // ADD
        alu_ctl = 3'b010;
        a = 32'hf0f0f0f0; b = 32'h0f0f0f0f; result_expected = 32'h00000000; #DELAY;
        assert_;
        a = 32'hffffffff; b = 32'hf0000000; result_expected = 32'hf0000000; #DELAY;
        assert_;

        // OR
        alu_ctl = 3'b011;
        a = 32'hf0f0f0f0; b = 32'h0f0f0f0f; result_expected = 32'hffffffff; #DELAY;
        assert_;
        a = 32'h000f000f; b = 32'hf000f000; result_expected = 32'hf00ff00f; #DELAY;
        assert_;

        // EOR
        alu_ctl = 3'b110;
        a = 32'hf0f0f0f0; b = 32'h0f0f0f0f; result_expected = 32'hffffffff; #DELAY;
        assert_;
        a = 32'hf0f0f0f0; b = 32'hf0f0f0f0; result_expected = 32'h00000000; #DELAY;
        assert_;

        // Cフラグ
        a = 32'hfffffffe; b = 32'h00000001; alu_ctl = 3'b000; #DELAY;
        assert (cv_flags[1] === 0) else $error("cv_flags[1] = %d, %d expected", cv_flags[1], 0);
        a = 32'hffffffff; b = 32'h00000001; alu_ctl = 3'b000; #DELAY;
        assert (cv_flags[1] === 1) else $error("cv_flags[1] = %d, %d expected", cv_flags[1], 1);
        a = 32'h0fffffff; b = 32'h10000000; alu_ctl = 3'b001; #DELAY;
        assert (cv_flags[1] === 0) else $error("cv_flags[1] = %d, %d expected", cv_flags[1], 0);
        a = 32'h0fffffff; b = 32'h0fffffff; alu_ctl = 3'b001; #DELAY;
        assert (cv_flags[1] === 1) else $error("cv_flags[1] = %d, %d expected", cv_flags[1], 1);

        // Vフラグ
        a = 2**31 - 1; b = 0; alu_ctl = 3'b000; #DELAY;
        assert (cv_flags[0] === 0) else $error("cv_flags[0] = %d, %d expected", cv_flags[0], 0);
        a = 2**31 - 1; b = 1; alu_ctl = 3'b000; #DELAY;
        assert (cv_flags[0] === 1) else $error("cv_flags[0] = %d, %d expected", cv_flags[0], 1);
        a = 32'h7ffffffe; b = 32'h00000001; alu_ctl = 3'b000; #DELAY;
        assert (cv_flags[0] === 0) else $error("cv_flags[0] = %d, %d expected", cv_flags[0], 0);
        a = 32'h7fffffff; b = 32'h00000001; alu_ctl = 3'b000; #DELAY;
        assert (cv_flags[0] === 1) else $error("cv_flags[0] = %d, %d expected", cv_flags[0], 1);
        a = -2**31; b = -1; alu_ctl = 3'b001; #DELAY;
        assert (cv_flags[0] === 0) else $error("cv_flags[0] = %d, %d expected", cv_flags[0], 0);
        a = -2**31; b = 1; alu_ctl = 3'b001; #DELAY;
        assert (cv_flags[0] === 1) else $error("cv_flags[0] = %d, %d expected", cv_flags[0], 1);

        $display("test completed");
        $finish;
    end
endmodule
