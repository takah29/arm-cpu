module AluDecoderTestbench;
    parameter DELAY = 10;

    logic alu_op, s;
    logic [3:0] cmd;
    logic [1:0] alu_ctl, flag_w, alu_ctl_expected, flag_w_expected;

    AluDecoder dut(.alu_op, .s, .cmd, .alu_ctl, .flag_w);

    task assert_;
        assert (alu_ctl === alu_ctl_expected) else $error("alu_ctl = %b, %b expected", alu_ctl, alu_ctl_expected);
        assert (flag_w === flag_w_expected) else $error("flag_w = %b, %b expected", flag_w, flag_w_expected);
    endtask

    initial begin
        // case1: not defined
        alu_op = '0; s = '1; cmd = 4'b0100; alu_ctl_expected = 2'b00; flag_w_expected = 2'b00; #DELAY;
        assert_;

        //alu_op = 1
        alu_op = 1'b1;

        // case2: ADD
        s = '0; cmd = 4'b0100; alu_ctl_expected = 2'b00; flag_w_expected = 2'b00; #DELAY;
        assert_;
        s = '1; alu_ctl_expected = 2'b00; flag_w_expected = 2'b11; #DELAY;
        assert_;

        // case3: SUB
        s = '0; cmd = 4'b0010; alu_ctl_expected = 2'b01; flag_w_expected = 2'b00; #DELAY;
        assert_;
        s = '1; alu_ctl_expected = 2'b01; flag_w_expected = 2'b11; #DELAY;
        assert_;

        // case4: AND
        s = '0; cmd = 4'b0000; alu_ctl_expected = 2'b10; flag_w_expected = 2'b00; #DELAY;
        assert_;
        s = '1; alu_ctl_expected = 2'b10; flag_w_expected = 2'b10; #DELAY;
        assert_;

        // case5: OR
        s = '0; cmd = 4'b1100; alu_ctl_expected = 2'b11; flag_w_expected = 2'b00; #DELAY;
        assert_;
        s = '1; alu_ctl_expected = 2'b11; flag_w_expected = 2'b10; #DELAY;
        assert_;

        $display("test completed");
        $finish;
    end
endmodule
