module ShifterTestbench;
    parameter DELAY = 10;

    logic [1:0] shift_type;
    logic [7:0] shift_num;
    logic not_shift, instr4;
    logic [31:0] x;
    logic carry;
    logic [31:0] shifter_operand, shifter_operand_exp;
    logic shifter_carry_out, shifter_carry_out_exp;

    Shifter dut(.shift_type, .shift_num, .not_shift, .instr4, .x, .carry, .shifter_operand, .shifter_carry_out);

    task assert_;
        assert (shifter_operand === shifter_operand_exp) else $error("shifter_operand = %b, %b expected", shifter_operand, shifter_operand_exp);
        assert (shifter_carry_out === shifter_carry_out_exp) else $error("shifter_carry_out = %b, %b expected", shifter_carry_out, shifter_carry_out_exp);
    endtask

    initial begin
        not_shift = 1'b0;
        carry = 1'b0;
        instr4 = 1'b0;

        // case: LSL
        shift_type = 2'b00;
        // shift_num = 0
        shift_num = 8'b0;
        x = '1; carry = 1'b0; shifter_operand_exp = '1; shifter_carry_out_exp = 1'b0; #DELAY;
        assert_;
        x = '1; carry = 1'b1; shifter_operand_exp = '1; shifter_carry_out_exp = 1'b1; #DELAY;
        assert_;
        // 0 < shift_num < 32
        shift_num = 8'h1;
        x = 32'h80000001; carry = 1'b0; shifter_operand_exp = 32'h2; shifter_carry_out_exp = 1'b1; #DELAY;
        assert_;
        x = 32'h80000001; carry = 1'b1; shifter_operand_exp = 32'h2; shifter_carry_out_exp = 1'b1; #DELAY;
        assert_;
        x = 32'h7ffffffe; carry = 1'b0; shifter_operand_exp = 32'hfffffffc; shifter_carry_out_exp = 1'b0; #DELAY;
        assert_;
        // shift_num = 32
        shift_num = 8'h20;
        x = '1; carry = 1'b0; shifter_operand_exp = '0; shifter_carry_out_exp = 1'b1; #DELAY;
        assert_;

        // case: LSR
        shift_type = 2'b01;
        // shift_num = 0
        shift_num = 8'b0;
        x = '1; carry = 1'b0; shifter_operand_exp = '1; shifter_carry_out_exp = 1'b0; #DELAY;
        assert_;
        x = '1; carry = 1'b1; shifter_operand_exp = '1; shifter_carry_out_exp = 1'b1; #DELAY;
        assert_;
        // 0 < shift_num < 32
        shift_num = 8'h1;
        x = 32'h80000001; carry = 1'b0; shifter_operand_exp = 32'h40000000; shifter_carry_out_exp = 1'b1; #DELAY;
        assert_;
        x = 32'h80000001; carry = 1'b1; shifter_operand_exp = 32'h40000000; shifter_carry_out_exp = 1'b1; #DELAY;
        assert_;
        x = 32'h7ffffffe; carry = 1'b0; shifter_operand_exp = 32'h3fffffff; shifter_carry_out_exp = 1'b0; #DELAY;
        assert_;
        // shift_num = 32
        shift_num = 8'h20;
        x = '1; carry = 1'b0; shifter_operand_exp = '0; shifter_carry_out_exp = 1'b1; #DELAY;
        assert_;

        // case: ASR
        shift_type = 2'b10;
        // shift_num = 0
        shift_num = 8'b0;
        x = '1; carry = 1'b0; shifter_operand_exp = '1; shifter_carry_out_exp = 1'b0; #DELAY;
        assert_;
        x = '1; carry = 1'b1; shifter_operand_exp = '1; shifter_carry_out_exp = 1'b1; #DELAY;
        assert_;
        // 0 < shift_num < 32
        shift_num = 8'h1;
        x = 32'h80000001; carry = 1'b0; shifter_operand_exp = 32'hc0000000; shifter_carry_out_exp = 1'b1; #DELAY;
        assert_;
        x = 32'h80000001; carry = 1'b1; shifter_operand_exp = 32'hc0000000; shifter_carry_out_exp = 1'b1; #DELAY;
        assert_;
        x = 32'h7ffffffe; carry = 1'b0; shifter_operand_exp = 32'h3fffffff; shifter_carry_out_exp = 1'b0; #DELAY;
        assert_;
        // shift_num = 32
        shift_num = 8'h20;
        x = 32'h80000000; carry = 1'b0; shifter_operand_exp = '1; shifter_carry_out_exp = 1'b1; #DELAY;
        assert_;
        x = 32'h7fffffff; carry = 1'b0; shifter_operand_exp = '0; shifter_carry_out_exp = 1'b0; #DELAY;
        assert_;

        // case: RRX
        shift_type = 2'b11;
        shift_num = 8'h0; instr4 = 1'b0;
        x = 32'h1; carry = 1'b0; shifter_operand_exp = 32'h0; shifter_carry_out_exp = 1'b1; #DELAY;
        assert_;
        x = 32'h1; carry = 1'b1; shifter_operand_exp = 32'h80000000; shifter_carry_out_exp = 1'b1; #DELAY;
        assert_;

        // case: ROR
        shift_type = 2'b11;
        // shift_num = 0
        shift_num = 8'b0; instr4 = 1'b1;
        x = '1; carry = 1'b0; shifter_operand_exp = '1; shifter_carry_out_exp = 1'b0; #DELAY;
        assert_;
        x = '1; carry = 1'b1; shifter_operand_exp = '1; shifter_carry_out_exp = 1'b1; #DELAY;
        assert_;
        // shift_num[4:0] = 0
        shift_num = 8'h0; instr4 = 1'b1;
        x = 32'h7fffffff; carry = 1'b0; shifter_operand_exp = 32'h7fffffff; shifter_carry_out_exp = 1'b0; #DELAY;
        assert_;
        x = 32'h80000000; carry = 1'b0; shifter_operand_exp = 32'h80000000; shifter_carry_out_exp = 1'b1; #DELAY;
        // shift_num[4:0] > 0
        shift_num = 8'h1; instr4 = 1'b0;
        x = 32'h80000001; carry = 1'b0; shifter_operand_exp = 32'hc0000000; shifter_carry_out_exp = 1'b1; #DELAY;
        assert_;
        x = 32'h7ffffffe; carry = 1'b0; shifter_operand_exp = 32'h3fffffff; shifter_carry_out_exp = 1'b0; #DELAY;
        assert_;

        // case: not shift
        not_shift = 1'b1;
        shift_type = 2'b11;
        shift_num = 8'b00011111; x = 32'h7fffffff; shifter_operand_exp = 32'h7fffffff; #DELAY;
        assert_;

        $display("test completed");
        $finish;
    end
endmodule
