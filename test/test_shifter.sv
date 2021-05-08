module ShifterTestbench;
    parameter DELAY = 10;

    logic [1:0] shift_type;
    logic [7:0] shift_num;
    logic not_shift, instr4;
    logic [31:0] x;
    logic carry;
    logic [31:0] y, y_expected;
    logic c, c_expected;

    Shifter dut(.shift_type, .shift_num, .not_shift, .instr4, .x, .carry, .y, .c);

    task assert_y;
        assert (y === y_expected) else $error("y = %b, %b expected", y, y_expected);
    endtask

    task assert_c;
        assert (c === c_expected) else $error("c = %b, %b expected", c, c_expected);
    endtask

    initial begin
        not_shift = 1'b0;
        carry = 1'b0;
        instr4 = 1'b0;

        // case: LSL
        shift_type = 2'b00;
        shift_num = '0; x = '1; y_expected = '1; #DELAY;
        assert_y;
        shift_num = 8'b00000001; x = '1; y_expected = 32'hfffffffe; #DELAY;
        assert_y;
        shift_num = 8'b00011111; x = '1; y_expected = 32'h80000000; #DELAY;
        assert_y;

        // case: LSR
        shift_type = 2'b01;
        shift_num = '0; x = '1; y_expected = '1; #DELAY;
        assert_y;
        shift_num = 8'b00000001; x = '1; y_expected = 32'h7fffffff; #DELAY;
        assert_y;
        shift_num = 8'b00011111; x = '1; y_expected = 32'h00000001; #DELAY;
        assert_y;

        // case: ASR
        shift_type = 2'b10;
        shift_num = '0; x = '1; y_expected = '1; #DELAY;
        assert_y;
        shift_num = 8'b00000001; x = '1; y_expected = 32'hffffffff; #DELAY;
        assert_y;
        shift_num = 8'b00011111; x = '1; y_expected = 32'hffffffff; #DELAY;
        assert_y;

        // case: RRX
        shift_type = 2'b11; carry = 1'b0;
        shift_num = '0; x = 32'h1; y_expected = '0; c_expected = 1'b1; #DELAY;
        assert_y;
        assert_c;
        shift_type = 2'b11; carry = 1'b1;
        shift_num = '0; x = '0; y_expected = 32'h80000000; c_expected = 1'b0; #DELAY;
        assert_y;
        assert_c;

        // case: ROR
        shift_type = 2'b11;
        shift_num = 8'b00000001; x = 32'b1; y_expected = 32'h80000000; #DELAY;
        assert_y;
        shift_num = 8'b00011111; x = 32'h7fffffff; y_expected = 32'hfffffffe; #DELAY;
        assert_y;
        // instr[4] = 1'b1 and shift_num = 0のとき
        instr4 = 1'b1;
        shift_num = 8'b0; x = 32'b1; y_expected = 32'b1; #DELAY;
        assert_y;

        // case: not shift
        not_shift = 1'b1;
        shift_type = 2'b11;
        shift_num = 8'b00011111; x = 32'h7fffffff; y_expected = 32'h7fffffff; #DELAY;
        assert_y;

        $display("test completed");
        $finish;
    end
endmodule
