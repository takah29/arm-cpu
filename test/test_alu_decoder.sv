module AluDecoderTestbench;
    parameter DELAY = 10;

    logic alu_op, s;
    logic [3:0] cmd;
    logic no_write, shift, swap;
    logic [1:0] flag_w;
    logic [2:0] alu_ctl;
    logic no_write_expected, shift_expected, swap_expected;
    logic [1:0] flag_w_expected;
    logic [2:0] alu_ctl_expected;

    AluDecoder dut(.alu_op, .s, .cmd, .no_write, .shift, .swap, .alu_ctl, .flag_w);

    task set_exp(
        input logic [2:0] alu_exp_in,
        input logic [1:0] flag_w_exp_in,
        input logic no_write_exp_in, shift_exp_in, swap_exp_in
        );
        alu_ctl_expected <= alu_exp_in;
        flag_w_expected <= flag_w_exp_in;
        no_write_expected <= no_write_exp_in;
        shift_expected <= shift_exp_in;
        swap_expected <= swap_exp_in;
    endtask

    task assert_;
        assert (alu_ctl === alu_ctl_expected) else $error("alu_ctl = %b, %b expected", alu_ctl, alu_ctl_expected);
        assert (flag_w === flag_w_expected) else $error("flag_w = %b, %b expected", flag_w, flag_w_expected);
        assert (no_write === no_write_expected) else $error("no_write = %b, %b expected", no_write, no_write_expected);
        assert (shift === shift_expected) else $error("shift = %b, %b expected", shift, shift_expected);
        assert (swap === swap_expected) else $error("swap = %b, %b expected", swap, swap_expected);
    endtask

    initial begin
        // case1: not defined
        alu_op = '0; s = '1; cmd = 4'b0100;
        set_exp(3'b000, 2'b00, 1'b0, 1'b0, 1'b0); #DELAY;
        assert_;

        //alu_op = 1
        alu_op = 1'b1;

        // case ADD
        s = '0; cmd = 4'b0100;
        set_exp(3'b000, 2'b00, 1'b0, 1'b0, 1'b0); #DELAY;
        assert_;
        s = '1;
        set_exp(3'b000, 2'b11, 1'b0, 1'b0, 1'b0); #DELAY;
        assert_;

        // case SUB
        s = '0; cmd = 4'b0010;
        set_exp(3'b001, 2'b00, 1'b0, 1'b0, 1'b0); #DELAY;
        assert_;
        s = '1;
        set_exp(3'b001, 2'b11, 1'b0, 1'b0, 1'b0); #DELAY;
        assert_;

        // case AND
        s = '0; cmd = 4'b0000;
        set_exp(3'b010, 2'b00, 1'b0, 1'b0, 1'b0); #DELAY;
        assert_;
        s = '1;
        set_exp(3'b010, 2'b10, 1'b0, 1'b0, 1'b0); #DELAY;
        assert_;

        // case OR
        s = '0; cmd = 4'b1100;
        set_exp(3'b011, 2'b00, 1'b0, 1'b0, 1'b0); #DELAY;
        assert_;
        s = '1;
        set_exp(3'b011, 2'b10, 1'b0, 1'b0, 1'b0); #DELAY;
        assert_;

        // case EOR
        s = '0; cmd = 4'b0001;
        set_exp(3'b110, 2'b00, 1'b0, 1'b0, 1'b0); #DELAY;
        assert_;
        s = '1;
        set_exp(3'b110, 2'b10, 1'b0, 1'b0, 1'b0); #DELAY;
        assert_;

        // case ADC
        s = '0; cmd = 4'b0101;
        set_exp(3'b100, 2'b00, 1'b0, 1'b0, 1'b0); #DELAY;
        assert_;
        s = '1;
        set_exp(3'b100, 2'b11, 1'b0, 1'b0, 1'b0); #DELAY;
        assert_;

        // case SBC
        s = '0; cmd = 4'b0110;
        set_exp(3'b101, 2'b00, 1'b0, 1'b0, 1'b0); #DELAY;
        assert_;
        s = '1;
        set_exp(3'b101, 2'b11, 1'b0, 1'b0, 1'b0); #DELAY;
        assert_;

        // case RSB
        s = '0; cmd = 4'b0011;
        set_exp(3'b001, 2'b00, 1'b0, 1'b0, 1'b1); #DELAY;
        assert_;
        s = '1;
        set_exp(3'b001, 2'b11, 1'b0, 1'b0, 1'b1); #DELAY;
        assert_;

        // case RSC
        s = '0; cmd = 4'b0111;
        set_exp(3'b101, 2'b00, 1'b0, 1'b0, 1'b1); #DELAY;
        assert_;
        s = '1;
        set_exp(3'b101, 2'b11, 1'b0, 1'b0, 1'b1); #DELAY;
        assert_;

        // case CMP
        s = '1; cmd = 4'b1010;
        set_exp(3'b001, 2'b11, 1'b1, 1'b0, 1'b0); #DELAY;
        assert_;

        // case CMN
        s = '1; cmd = 4'b1011;
        set_exp(3'b000, 2'b11, 1'b1, 1'b0, 1'b0); #DELAY;
        assert_;

        // case TST
        s = '1; cmd = 4'b1000;
        set_exp(3'b010, 2'b10, 1'b1, 1'b0, 1'b0); #DELAY;
        assert_;

        // case TEQ
        s = '1; cmd = 4'b1001;
        set_exp(3'b110, 2'b10, 1'b1, 1'b0, 1'b0); #DELAY;
        assert_;

        // case LSL, LSR, ASR, ROR
        s = '0; cmd = 4'b1101;
        set_exp(3'b0xx, 2'b00, 1'b0, 1'b1, 1'b0); #DELAY;
        assert_;
        s = '1;
        set_exp(3'b0xx, 2'b10, 1'b0, 1'b1, 1'b0); #DELAY;
        assert_;

        $display("test completed");
        $finish;
    end
endmodule
