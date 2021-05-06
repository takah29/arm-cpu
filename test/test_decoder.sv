module DecoderTestbench;
    parameter DELAY = 10;

    logic [1:0] op;
    logic [5:0] funct;
    logic [3:0] instr74;
    logic [3:0] rd;
    logic pcs, reg_w3, reg_w1, mem_w, mem_to_reg, alu_src, mult, no_write, swap, inv;
    logic [1:0] flag_w, imm_src, reg_src, result_src;
    logic [2:0] alu_ctl;
    logic pcs_exp, reg_w3_exp, reg_w1_exp, mem_w_exp, mem_to_reg_exp, alu_src_exp, mult_exp, no_write_exp, swap_exp, inv_exp;
    logic [1:0] flag_w_exp, imm_src_exp, reg_src_exp, result_src_exp;
    logic [2:0] alu_ctl_exp;

    Decoder dut(
    .op,
    .funct,
    .instr74,
    .rd,
    .pcs,
    .reg_w3,
    .reg_w1,
    .mem_w,
    .mem_to_reg,
    .alu_src,
    .no_write,
    .swap,
    .inv,
    .flag_w,
    .imm_src,
    .result_src,
    .reg_src,
    .mult,
    .alu_ctl
    );

    task assert_pcs;
        assert (pcs === pcs_exp) else $error("pcs = %b, %b expected", pcs, pcs_exp);
    endtask

    task assert_reg_w3;
        assert (reg_w3 === reg_w3_exp) else $error("reg_w3 = %b, %b expected", reg_w3, reg_w3_exp);
    endtask

    task assert_reg_w1;
        assert (reg_w1 === reg_w1_exp) else $error("reg_w1 = %b, %b expected", reg_w1, reg_w1_exp);
    endtask

    task assert_mem_w;
        assert (mem_w  === mem_w_exp ) else $error("mem_w = %b, %b expected", mem_w, mem_w_exp);
    endtask

    task assert_mem_to_reg;
        assert (mem_to_reg === mem_to_reg_exp) else $error("mem_to_reg = %b, %b expected", mem_to_reg, mem_to_reg_exp);
    endtask

    task assert_alu_src;
        assert (alu_src === alu_src_exp) else $error("alu_src = %b, %b expected", alu_src, alu_src_exp);
    endtask

    task assert_no_write;
        assert (no_write === no_write_exp) else $error("no_write = %b, %b expected", no_write, no_write_exp);
    endtask

    task assert_swap;
        assert (swap === swap_exp) else $error("swap = %b, %b expected", swap, swap_exp);
    endtask

    task assert_inv;
        assert (inv === inv_exp) else $error("inv = %b, %b expected", inv, inv_exp);
    endtask

    task assert_flag_w;
        assert (flag_w === flag_w_exp) else $error("flag_w = %b, %b expected", flag_w, flag_w_exp);
    endtask

    task assert_imm_src;
        assert (imm_src === imm_src_exp) else $error("imm_src = %b, %b expected", imm_src, imm_src_exp);
    endtask

    task assert_result_src;
        assert (result_src === result_src_exp) else $error("result_src = %b, %b expected", result_src, result_src_exp);
    endtask

    task assert_reg_src;
        assert (reg_src === reg_src_exp) else $error("reg_src = %b, %b expected", reg_src, reg_src_exp);
    endtask

    task assert_mult;
        assert (mult === mult_exp) else $error("mult = %b, %b expected", mult, mult_exp);
    endtask

    task assert_alu_ctl;
        assert (alu_ctl === alu_ctl_exp) else $error("alu_ctl = %b, %b expected", alu_ctl, alu_ctl_exp);
    endtask

    initial begin
        // case: pcs test
        op = 2'b00; funct = 6'b000000; rd = 0; instr74 = 4'b0000; pcs_exp = 0; #DELAY;
        assert_pcs;
        op = 2'b00; funct = 6'b000000; rd = 15; instr74 = 4'b0000; pcs_exp = 1; #DELAY;
        assert_pcs;
        op = 2'b10; funct = 6'b100000; rd = 0; instr74 = 4'b0000; pcs_exp = 1; #DELAY;
        assert_pcs;

        // case: reg_w3 test
        op = 2'b01; funct = 6'b010000; rd = 0; instr74 = 4'b0000; reg_w3_exp = 0; #DELAY;
        assert_reg_w3;
        op = 2'b01; funct = 6'b000001; rd = 0; instr74 = 4'b0000; reg_w3_exp = 1; #DELAY;
        assert_reg_w3;

        // case: reg_w1 test
        op = 2'b01; funct = 6'b011000; rd = 0; instr74 = 4'b0000; reg_w1_exp = 1'b0; #DELAY;
        assert_reg_w1;
        op = 2'b01; funct = 6'b011010; rd = 0; instr74 = 4'b0000; reg_w1_exp = 1'b1; #DELAY;
        assert_reg_w1;

        // case: mem_w test
        op = 2'b00; funct = 6'b000000; rd = 0; instr74 = 4'b0000; mem_w_exp = 0; #DELAY;
        assert_mem_w;
        op = 2'b01; funct = 6'b010000; rd = 0; instr74 = 4'b0000; mem_w_exp = 1; #DELAY;
        assert_mem_w;

        //case: mem_to_reg test
        op = 2'b00; funct = 6'b000000; rd = 0; instr74 = 4'b0000; mem_to_reg_exp = 0; #DELAY;
        assert_mem_to_reg;
        op = 2'b01; funct = 6'b000001; rd = 0; instr74 = 4'b0000; mem_to_reg_exp = 1; #DELAY;
        assert_mem_to_reg;

        // case: alu_src test
        op = 2'b00; funct = 6'b000000; rd = 0; instr74 = 4'b0000; alu_src_exp = 0; #DELAY;
        assert_alu_src;
        op = 2'b00; funct = 6'b100000; rd = 0; instr74 = 4'b0000; alu_src_exp = 1; #DELAY;
        assert_alu_src;

        // case: flag_w test
        op = 2'b00; funct = 6'b001000; rd = 0; instr74 = 4'b0000; flag_w_exp = 2'b00; #DELAY;
        assert_flag_w;
        op = 2'b00; funct = 6'b001001; rd = 0; instr74 = 4'b0000; flag_w_exp = 2'b11; #DELAY;
        assert_flag_w;
        op = 2'b00; funct = 6'b000001; rd = 0; instr74 = 4'b0000; flag_w_exp = 2'b10; #DELAY;
        assert_flag_w;

        // case: imm_src test
        op = 2'b00; funct = 6'b100000; rd = 0; instr74 = 4'b0000; imm_src_exp = 2'b00; #DELAY;
        assert_imm_src;
        op = 2'b01; funct = 6'b010000; rd = 0; instr74 = 4'b0000; imm_src_exp = 2'b01; #DELAY;
        assert_imm_src;
        op = 2'b10; funct = 6'b100000; rd = 0; instr74 = 4'b0000; imm_src_exp = 2'b10; #DELAY;
        assert_imm_src;

        // case: reg_src test
        op = 2'b00; funct = 6'b000000; rd = 0; instr74 = 4'b0000; reg_src_exp = 2'b00; #DELAY;
        assert_reg_src;
        op = 2'b10; funct = 6'b100000; rd = 0; instr74 = 4'b0000; reg_src_exp = 2'b01; #DELAY;
        assert_reg_src;
        op = 2'b10; funct = 6'b110000; rd = 0; instr74 = 4'b0000; reg_src_exp = 2'b11; #DELAY;
        assert_reg_src;

        // case: mult test
        op = 2'b00; funct = 6'b000000; rd = 0; instr74 = 4'b0000; mult_exp = 1'b0; #DELAY;
        assert_mult;
        op = 2'b00; funct = 6'b001000; rd = 0; instr74 = 4'b1001; mult_exp = 1'b1; #DELAY;
        assert_mult;

        // case: alu_ctl test
        op = 2'b00; funct = 6'b001000; rd = 0; instr74 = 4'b0000; alu_ctl_exp = 3'b000; #DELAY;
        assert_alu_ctl;
        op = 2'b00; funct = 6'b000100; rd = 0; instr74 = 4'b0000; alu_ctl_exp = 3'b001; #DELAY;
        assert_alu_ctl;
        op = 2'b00; funct = 6'b000000; rd = 0; instr74 = 4'b0000; alu_ctl_exp = 3'b010; #DELAY;
        assert_alu_ctl;
        op = 2'b00; funct = 6'b011000; rd = 0; instr74 = 4'b0000; alu_ctl_exp = 3'b011; #DELAY;
        assert_alu_ctl;
        // ADC
        op = 2'b00; funct = 6'b001010; rd = 0; instr74 = 4'b0000; alu_ctl_exp = 3'b100; #DELAY;
        assert_alu_ctl;

        // case: no_write test
        op = 2'b00; funct = 6'b001000; rd = 0; instr74 = 4'b0000; no_write_exp = 1'b0; #DELAY;
        assert_no_write;
        op = 2'b00; funct = 6'b010101; rd = 0; instr74 = 4'b0000; no_write_exp = 1'b1; #DELAY;
        assert_no_write;

        // case: result_src test
        op = 2'b00; funct = 6'b100000; rd = 0; instr74 = 4'b0000; result_src_exp = 2'b00; #DELAY;
        assert_result_src;
        op = 2'b00; funct = 6'b011010; rd = 0; instr74 = 4'b0000; result_src_exp = 2'b01; #DELAY;
        assert_result_src;
        op = 2'b01; funct = 6'b000001; rd = 0; instr74 = 4'b0000; result_src_exp = 2'b10; #DELAY;
        assert_result_src;

        // case: swap test
        op = 2'b00; funct = 6'b001000; rd = 0; instr74 = 4'b0000; swap_exp = 1'b0; #DELAY;
        assert_swap;
        op = 2'b00; funct = 6'b000111; rd = 0; instr74 = 4'b0000; swap_exp = 1'b1; #DELAY;
        assert_swap;

        // case: inv test
        op = 2'b00; funct = 6'b001000; rd = 0; instr74 = 4'b0000; inv_exp = 1'b0; #DELAY;
        assert_inv;
        op = 2'b00; funct = 6'b011101; rd = 0; instr74 = 4'b0000; inv_exp = 1'b1; #DELAY;
        assert_inv;

        $display("test completed");
        $finish;
    end
endmodule
