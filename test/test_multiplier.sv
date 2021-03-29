module MultiplierTestbench;
    parameter DELAY = 10;

    logic [31:0] a, b, c, d;
    logic [2:0] cmd;
    logic [31:0] ret1, ret2;
    logic [31:0] ret1_exp, ret2_exp;

    Multiplier dut(.a, .b, .c, .d, .cmd, .ret1, .ret2);

    task assert_ret1;
        assert (ret1 === ret1_exp) else $error("ret1 = %h, %h expected", ret1, ret1_exp);
    endtask

    task assert_ret2;
        assert (ret2 === ret2_exp) else $error("ret2 = %h, %h expected", ret2, ret2_exp);
    endtask

    initial begin
        // MUL
        cmd = 3'b000;
        a = 1000; b = 1000; ret1_exp = 1000000;
        #DELAY;
        assert_ret1;
        a = 32'hffffffff; b = 32'hffffffff; ret1_exp = 32'h00000001;
        #DELAY;
        assert_ret1;

        // MLA
        cmd = 3'b001;
        a = 1000; b = 1000; d = 2000; ret1_exp = 1002000;
        #DELAY;
        assert_ret1;
        a = 32'hffffffff; b = 32'hffffffff; d = 32'hffffffff; ret1_exp = 32'h00000000;
        #DELAY;
        assert_ret1;

        // UMULL
        cmd = 3'b100;
        a = 1000; b = 1000; ret1_exp = 0; ret2_exp = 1000000;
        #DELAY;
        assert_ret1;
        assert_ret2;
        a = 32'hffffffff; b = 32'hffffffff; ret1_exp = 32'hfffffffe; ret2_exp = 32'h00000001;
        #DELAY;
        assert_ret1;
        assert_ret2;

        // UMLAL
        cmd = 3'b101;
        a = 1000; b = 2000; c = 32'hffffffff; d = 32'hffff0000;
        ret1_exp = 32'h0; ret2_exp = 32'h001d8480;
        #DELAY;
        assert_ret1;
        assert_ret2;
        a = 32'hffffffff; b = 32'hffffffff; c = 32'hffffffff; d = 32'hffffffff;
        ret1_exp = 32'hfffffffe; ret2_exp = 32'h0;
        #DELAY;
        assert_ret1;
        assert_ret2;

        // SMULL
        cmd = 3'b110;
        a = 32'hffffffff; b = 32'h00000002;
        ret1_exp = 32'hffffffff; ret2_exp = 32'hfffffffe;
        #DELAY;
        assert_ret1;
        assert_ret2;
        a = 32'hffffffff; b = 32'hffffffff;
        ret1_exp = 32'h00000000; ret2_exp = 32'h00000001;
        #DELAY;
        assert_ret1;
        assert_ret2;

        // SMLAL
        cmd = 3'b111;
        a = 32'hffffffff; b = 32'h00000002; c = 32'hffffffff; d = 32'hffffffff;
        ret1_exp = 32'hffffffff; ret2_exp = 32'hfffffffd;
        #DELAY;
        assert_ret1;
        assert_ret2;

        $display("test completed");
        $finish;
    end
endmodule
