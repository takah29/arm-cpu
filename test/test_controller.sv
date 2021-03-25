module ControllerTestbench;
    parameter HALF_CYCLE = 500;
    parameter DELAY = 100;

    logic clk, reset;
    logic [1:0] op;
    logic [3:0] cond, alu_flags, rd;
    logic [5:0] funct;
    logic pc_src, reg_write, mem_write, mem_to_reg, alu_src, shift, carry, swap, inv;
    logic [1:0] imm_src, reg_src;
    logic [2:0] alu_ctl;
    logic pc_src_exp, reg_write_exp, mem_write_exp, mem_to_reg_exp, alu_src_exp, shift_exp, carry_exp, swap_exp, inv_exp;
    logic [1:0] imm_src_exp, reg_src_exp;
    logic [2:0] alu_ctl_exp;

    Controller dut(
    .clk,
    .reset,
    .op,
    .cond,
    .alu_flags,
    .rd,
    .funct,
    .pc_src,
    .reg_write,
    .mem_write,
    .mem_to_reg,
    .alu_src,
    .shift,
    .carry,
    .swap,
    .inv,
    .imm_src,
    .reg_src,
    .alu_ctl
    );


    task assert_pc_src;
        assert (pc_src === pc_src_exp) else $error("pc_src = %b, %b expected", pc_src, pc_src_exp);
    endtask

    task assert_reg_write;
        assert (reg_write === reg_write_exp) else $error("reg_write = %b, %b expected", reg_write, reg_write_exp);
    endtask

    task assert_mem_write;
        assert (mem_write === mem_write_exp) else $error("mem_write = %b, %b expected", mem_write, mem_write_exp);
    endtask

    task assert_mem_to_reg;
        assert (mem_to_reg === mem_to_reg_exp) else $error("mem_to_reg = %b, %b expected", mem_to_reg, mem_to_reg_exp);
    endtask

    task assert_alu_src;
        assert (alu_src === alu_src_exp) else $error("alu_src = %b, %b expected", alu_src, alu_src_exp);
    endtask

    task assert_shift;
        assert (shift === shift_exp) else $error("shift = %b, %b expected", shift, shift_exp);
    endtask

    task assert_swap;
        assert (swap === swap_exp) else $error("swap = %b, %b expected", swap, swap_exp);
    endtask

    task assert_inv;
        assert (inv === inv_exp) else $error("inv = %b, %b expected", inv, inv_exp);
    endtask

    task assert_carry;
        assert (carry === carry_exp) else $error("carry = %b, %b expected", carry, carry_exp);
    endtask

    task assert_imm_src;
        assert (imm_src === imm_src_exp) else $error("imm_src = %b, %b expected", imm_src, imm_src_exp);
    endtask

    task assert_reg_src;
        assert (reg_src === reg_src_exp) else $error("reg_src = %b, %b expected", reg_src, reg_src_exp);
    endtask

    task assert_alu_ctl;
        assert (alu_ctl === alu_ctl_exp) else $error("alu_ctl = %b, %b expected", alu_ctl, alu_ctl_exp);
    endtask

    always begin
        clk = 0;
        #HALF_CYCLE;
        clk = 1;
        #HALF_CYCLE;
    end

    initial begin
        // case: pc_src test
        op = 2'b00; cond = 4'b1110; alu_flags = 4'b0000; rd = 0; funct = 6'b000000; pc_src_exp = 1'b0;
        @(posedge clk); #DELAY;
        assert_pc_src;
        op = 2'b10; cond = 4'b1110; alu_flags = 4'b0000; rd = 0; funct = 6'b000000; pc_src_exp = 1'b1;
        @(posedge clk); #DELAY;
        assert_pc_src;

        // reg_write test
        op = 2'b01; cond = 4'b1110; alu_flags = 4'b0000; rd = 0; funct = 6'b000000; reg_write_exp = 1'b0;
        @(posedge clk); #DELAY;
        assert_reg_write;
        op = 2'b01; cond = 4'b1110; alu_flags = 4'b0000; rd = 0; funct = 6'b000001; reg_write_exp = 1'b1;
        @(posedge clk); #DELAY;
        assert_reg_write;

        // mem_write test
        op = 2'b00; cond = 4'b1110; alu_flags = 4'b0000; rd = 0; funct = 6'b000000; mem_write_exp = 1'b0;
        @(posedge clk); #DELAY;
        assert_mem_write;
        op = 2'b01; cond = 4'b1110; alu_flags = 4'b0000; rd = 0; funct = 6'b000000; mem_write_exp = 1'b1;
        @(posedge clk); #DELAY;
        assert_mem_write;

        // mem_to_reg test
        op = 2'b00; cond = 4'b0000; alu_flags = 4'b0000; rd = 0; funct = 6'b000000; mem_to_reg_exp = 1'b0;
        @(posedge clk); #DELAY;
        assert_mem_to_reg;
        op = 2'b01; cond = 4'b0000; alu_flags = 4'b0000; rd = 0; funct = 6'b000001; mem_to_reg_exp = 1'b1;
        @(posedge clk); #DELAY;
        assert_mem_to_reg;

        // alu_src test
        op = 2'b00; cond = 4'b0000; alu_flags = 4'b0000; rd = 0; funct = 6'b000000; alu_src_exp = 1'b0;
        @(posedge clk); #DELAY;
        assert_alu_src;
        op = 2'b01; cond = 4'b0000; alu_flags = 4'b0000; rd = 0; funct = 6'b000001; alu_src_exp = 1'b1;
        @(posedge clk); #DELAY;
        assert_alu_src;

        // shift test
        op = 2'b00; cond = 4'b0000; alu_flags = 4'b0000; rd = 0; funct = 6'b000000; shift_exp = 2'b0;
        @(posedge clk); #DELAY;
        assert_shift;
        op = 2'b00; cond = 4'b0000; alu_flags = 4'b0000; rd = 0; funct = 6'b011010; shift_exp = 2'b1;
        @(posedge clk); #DELAY;
        assert_shift;

        // carry test
        op = 2'b00; cond = 4'b0000; alu_flags = 4'b0000; rd = 0; funct = 6'b001001; carry_exp = 2'b0;
        dut.cond_logic.cond_ex = 1;
        @(posedge clk); #DELAY;
        assert_carry;
        op = 2'b00; cond = 4'b0000; alu_flags = 4'b0010; rd = 0; funct = 6'b001011; carry_exp = 2'b1;
        dut.cond_logic.cond_ex = 1;
        @(posedge clk); #DELAY;
        assert_carry;

        // swap test
        op = 2'b00; cond = 4'b0000; alu_flags = 4'b0000; rd = 0; funct = 6'b001001; swap_exp = 2'b0;
        dut.cond_logic.cond_ex = 1;
        @(posedge clk); #DELAY;
        assert_swap;
        op = 2'b00; cond = 4'b0000; alu_flags = 4'b0010; rd = 0; funct = 6'b000111; swap_exp = 2'b1;
        dut.cond_logic.cond_ex = 1;
        @(posedge clk); #DELAY;
        assert_swap;

        // inv test
        op = 2'b00; cond = 4'b0000; alu_flags = 4'b0000; rd = 0; funct = 6'b001001; inv_exp = 2'b0;
        dut.cond_logic.cond_ex = 1;
        @(posedge clk); #DELAY;
        assert_inv;
        op = 2'b00; cond = 4'b0000; alu_flags = 4'b0010; rd = 0; funct = 6'b011101; inv_exp = 2'b1;
        dut.cond_logic.cond_ex = 1;
        @(posedge clk); #DELAY;
        assert_inv;

        // imm_src test
        op = 2'b00; cond = 4'b0000; alu_flags = 4'b0000; rd = 0; funct = 6'b100000; imm_src_exp = 2'b00;
        @(posedge clk); #DELAY;
        assert_imm_src;
        op = 2'b01; cond = 4'b0000; alu_flags = 4'b0000; rd = 0; funct = 6'b000000; imm_src_exp = 2'b01;
        @(posedge clk); #DELAY;
        assert_imm_src;
        op = 2'b10; cond = 4'b0000; alu_flags = 4'b0000; rd = 0; funct = 6'b000000; imm_src_exp = 2'b10;
        @(posedge clk); #DELAY;
        assert_imm_src;

        // reg_src test
        op = 2'b00; cond = 4'b0000; alu_flags = 4'b0000; rd = 0; funct = 6'b000000; reg_src_exp = 3'b00;
        @(posedge clk); #DELAY;
        assert_reg_src;
        op = 2'b01; cond = 4'b0000; alu_flags = 4'b0000; rd = 0; funct = 6'b000000; reg_src_exp = 3'b10;
        @(posedge clk); #DELAY;
        assert_reg_src;

        // alu_ctl test
        op = 2'b00; cond = 4'b0000; alu_flags = 4'b0000; rd = 0; funct = 6'b001000; alu_ctl_exp = 3'b000;
        @(posedge clk); #DELAY;
        assert_alu_ctl;
        op = 2'b00; cond = 4'b0000; alu_flags = 4'b0000; rd = 0; funct = 6'b000100; alu_ctl_exp = 3'b001;
        @(posedge clk); #DELAY;
        assert_alu_ctl;
        op = 2'b00; cond = 4'b0000; alu_flags = 4'b0000; rd = 0; funct = 6'b000000; alu_ctl_exp = 3'b010;
        @(posedge clk); #DELAY;
        assert_alu_ctl;
        op = 2'b00; cond = 4'b0000; alu_flags = 4'b0000; rd = 0; funct = 6'b011000; alu_ctl_exp = 3'b011;
        @(posedge clk); #DELAY;
        assert_alu_ctl;
        // ADC
        op = 2'b00; cond = 4'b0000; alu_flags = 4'b0000; rd = 0; funct = 6'b001010; alu_ctl_exp = 3'b100;
        @(posedge clk); #DELAY;
        assert_alu_ctl;

        $display("test completed");
        $finish;
    end
endmodule
