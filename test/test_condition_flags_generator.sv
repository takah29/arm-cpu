module ConditionFlagsGeneratorTestbench;
    parameter DELAY = 10;

    logic [31:0] result1, result2;
    logic [1:0] cv_flags;
    logic shifter_carry_out;
    logic [7:0] instr_11_4;
    logic not_alu, mult;
    logic [3:0] cond_flags, cond_flags_exp;

    ConditionFlagsGenerator dut(.result1, .result2, .cv_flags, .shifter_carry_out, .instr_11_4, .not_alu, .mult, .cond_flags);

    task assert_cond_flags(input int num, input expected);
        // cond_flags = {n, z, c, v}
        assert (cond_flags[num] === expected) else $error("cond_flags[%1d] = %d, %d expected", num, cond_flags[num], expected);
    endtask

    initial begin
        // alu case
        instr_11_4 = 8'b0; not_alu = 1'b0; mult = 1'b0;

        // n flag check
        result1 = 32'h80000000; result2 = '0;
        cv_flags = 2'b00; shifter_carry_out = 1'b0;
        #DELAY;
        assert_cond_flags(3, 1);

        // z flag check
        result1 = '0; result2 = '0;
        cv_flags = 2'b00; shifter_carry_out = 1'b0;
        #DELAY;
        assert_cond_flags(2, 1);

        // c flag check
        result1 = '0; result2 = '0;
        cv_flags = 2'b10; shifter_carry_out = 1'b0;
        #DELAY;
        assert_cond_flags(1, 1);

        // v flag check
        result1 = '0; result2 = '0;
        cv_flags = 2'b01; shifter_carry_out = 1'b0;
        #DELAY;
        assert_cond_flags(0, 1);


        // shifter case
        instr_11_4 = 8'b00000_11_0; not_alu = 1'b1; mult = 1'b0;

        // n flag check
        result1 = 32'h80000000; result2 = '0;
        cv_flags = 2'b00; shifter_carry_out = 1'b0;
        #DELAY;
        assert_cond_flags(3, 1);

        // z flag check
        result1 = '0; result2 = '0;
        cv_flags = 2'b00; shifter_carry_out = 1'b0;
        #DELAY;
        assert_cond_flags(2, 1);

        // c flag check
        result1 = '0; result2 = '0;
        cv_flags = 2'b00; shifter_carry_out = 1'b1;
        #DELAY;
        assert_cond_flags(1, 1);

        // v flag check
        result1 = '0; result2 = '0;
        cv_flags = 2'b01; shifter_carry_out = 1'b0;
        #DELAY;
        assert_cond_flags(0, 0);


        // mult case
        instr_11_4 = 8'b0; not_alu = 1'b0; mult = 1'b1;

        // n flag check
        result1 = '0; result2 = 32'h80000000;
        cv_flags = 2'b00; shifter_carry_out = 1'b0;
        #DELAY;
        assert_cond_flags(3, 1);

        // z flag check
        result1 = '0; result2 = '0;
        cv_flags = 2'b00; shifter_carry_out = 1'b0;
        #DELAY;
        assert_cond_flags(2, 1);

        // c flag check
        result1 = '0; result2 = '0;
        cv_flags = 2'b00; shifter_carry_out = 1'b0;
        #DELAY;
        assert_cond_flags(1, 0);

        // v flag check
        result1 = '0; result2 = '0;
        cv_flags = 2'b01; shifter_carry_out = 1'b0;
        #DELAY;
        assert_cond_flags(0, 0);

        $display("test completed");
        $finish;
    end
endmodule
