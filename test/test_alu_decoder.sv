module AluDecoderTestbench;
    parameter DELAY = 10;

    logic alu_op, s;
    logic [3:0] cmd;
    logic no_write, shift;
    logic [1:0] alu_ctl, flag_w;
    logic no_write_expected, shift_expected;
    logic [1:0] alu_ctl_expected, flag_w_expected;

    AluDecoder dut(.alu_op, .s, .cmd, .no_write, .shift, .alu_ctl, .flag_w);

    task assert_;
        assert (alu_ctl === alu_ctl_expected) else $error("alu_ctl = %b, %b expected", alu_ctl, alu_ctl_expected);
        assert (flag_w === flag_w_expected) else $error("flag_w = %b, %b expected", flag_w, flag_w_expected);
        assert (no_write === no_write_expected) else $error("no_write = %b, %b expected", no_write, no_write_expected);
        assert (shift === shift_expected) else $error("shift = %b, %b expected", shift, shift_expected);
    endtask

    initial begin
        // case1: not defined
        alu_op = '0; s = '1; cmd = 4'b0100;
        alu_ctl_expected = 2'b00; flag_w_expected = 2'b00; no_write_expected = 1'b0; shift_expected = 1'b0; #DELAY;
        assert_;

        //alu_op = 1
        alu_op = 1'b1;

        // case2: ADD
        s = '0; cmd = 4'b0100;
        alu_ctl_expected = 2'b00; flag_w_expected = 2'b00; no_write_expected = 1'b0; shift_expected = 1'b0; #DELAY;
        assert_;
        s = '1;
        alu_ctl_expected = 2'b00; flag_w_expected = 2'b11; no_write_expected = 1'b0; shift_expected = 1'b0; #DELAY;
        assert_;

        // case3: SUB
        s = '0; cmd = 4'b0010;
        alu_ctl_expected = 2'b01; flag_w_expected = 2'b00; no_write_expected = 1'b0; shift_expected = 1'b0; #DELAY;
        assert_;
        s = '1;
        alu_ctl_expected = 2'b01; flag_w_expected = 2'b11; no_write_expected = 1'b0; shift_expected = 1'b0; #DELAY;
        assert_;

        // case4: AND
        s = '0; cmd = 4'b0000;
        alu_ctl_expected = 2'b10; flag_w_expected = 2'b00; no_write_expected = 1'b0; shift_expected = 1'b0; #DELAY;
        assert_;
        s = '1;
        alu_ctl_expected = 2'b10; flag_w_expected = 2'b10; no_write_expected = 1'b0; shift_expected = 1'b0; #DELAY;
        assert_;

        // case5: OR
        s = '0; cmd = 4'b1100;
        alu_ctl_expected = 2'b11; flag_w_expected = 2'b00; no_write_expected = 1'b0; shift_expected = 1'b0; #DELAY;
        assert_;
        s = '1;
        alu_ctl_expected = 2'b11; flag_w_expected = 2'b10; no_write_expected = 1'b0; shift_expected = 1'b0; #DELAY;
        assert_;

        // case6: CMP
        s = '1; cmd = 4'b1010;
        alu_ctl_expected = 2'b01; flag_w_expected = 2'b11; no_write_expected = 1'b1; shift_expected = 1'b0; #DELAY;
        assert_;

        // case7: TST
        s = '1; cmd = 4'b1000;
        alu_ctl_expected = 2'b10; flag_w_expected = 2'b10; no_write_expected = 1'b1; shift_expected = 1'b0; #DELAY;
        assert_;

        // case8: LSL
        s = '0; cmd = 4'b1101;
        alu_ctl_expected = 2'bxx; flag_w_expected = 2'b00; no_write_expected = 1'b0; shift_expected = 1'b1; #DELAY;
        assert_;
        s = '1;
        alu_ctl_expected = 2'bxx; flag_w_expected = 2'b10; no_write_expected = 1'b0; shift_expected = 1'b1; #DELAY;
        assert_;

        $display("test completed");
        $finish;
    end
endmodule
