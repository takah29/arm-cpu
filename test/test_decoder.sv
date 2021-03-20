module DecoderTestbench;
    parameter DELAY = 10;

    logic [1:0] op;
    logic [5:0] funct;
    logic [3:0] rd;
    logic pcs, reg_w, mem_w, mem_to_reg, alu_src, no_write, shift;
    logic [1:0] flag_w, imm_src;
    logic [2:0] reg_src, alu_ctl;
    logic pcs_exp, reg_w_exp, mem_w_exp, mem_to_reg_exp, alu_src_exp, no_write_exp, shift_exp;
    logic [1:0] flag_w_exp, imm_src_exp;
    logic [2:0] reg_src_exp, alu_ctl_exp;

    Decoder dut(
    .op,
    .funct,
    .rd,
    .pcs,
    .reg_w,
    .mem_w,
    .mem_to_reg,
    .alu_src,
    .no_write,
    .shift,
    .flag_w,
    .imm_src,
    .reg_src,
    .alu_ctl
    );

    task assert_pcs;
        assert (pcs === pcs_exp) else $error("pcs = %b, %b expected", pcs, pcs_exp);
    endtask

    task assert_reg_w;
        assert (reg_w === reg_w_exp) else $error("reg_w = %b, %b expected", reg_w, reg_w_exp);
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

    task assert_shift;
        assert (shift === shift_exp) else $error("shift = %b, %b expected", shift, shift_exp);
    endtask

    task assert_flag_w;
        assert (flag_w === flag_w_exp) else $error("flag_w = %b, %b expected", flag_w, flag_w_exp);
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

    initial begin
        // case: pcs test
        op = 2'b00; funct = 6'b000000; rd = 0; pcs_exp = 0; #DELAY;
        assert_pcs;
        op = 2'b00; funct = 6'b000000; rd = 15; pcs_exp = 1; #DELAY;
        assert_pcs;
        op = 2'b10; funct = 6'b000000; rd = 0; pcs_exp = 1; #DELAY;
        assert_pcs;

        // case: reg_w test
        op = 2'b10; funct = 6'b000000; rd = 0; reg_w_exp = 0; #DELAY;
        assert_reg_w;
        op = 2'b01; funct = 6'b000001; rd = 0; reg_w_exp = 1; #DELAY;
        assert_reg_w;

        // case: mem_w test
        op = 2'b00; funct = 6'b000000; rd = 0; mem_w_exp = 0; #DELAY;
        assert_mem_w;
        op = 2'b01; funct = 6'b000000; rd = 0; mem_w_exp = 1; #DELAY;
        assert_mem_w;

        //case: mem_to_reg test
        op = 2'b00; funct = 6'b000000; rd = 0; mem_to_reg_exp = 0; #DELAY;
        assert_mem_to_reg;
        op = 2'b01; funct = 6'b000001; rd = 0; mem_to_reg_exp = 1; #DELAY;
        assert_mem_to_reg;

        // case: alu_src test
        op = 2'b00; funct = 6'b000000; rd = 0; alu_src_exp = 0; #DELAY;
        assert_alu_src;
        op = 2'b00; funct = 6'b100000; rd = 0; alu_src_exp = 1; #DELAY;
        assert_alu_src;

        // case: flag_w test
        op = 2'b00; funct = 6'b001000; rd = 0; flag_w_exp = 2'b00; #DELAY;
        assert_flag_w;
        op = 2'b00; funct = 6'b001001; rd = 0; flag_w_exp = 2'b11; #DELAY;
        assert_flag_w;
        op = 2'b00; funct = 6'b000001; rd = 0; flag_w_exp = 2'b10; #DELAY;
        assert_flag_w;

        // case: imm_src test
        op = 2'b00; funct = 6'b100000; rd = 0; imm_src_exp = 2'b00; #DELAY;
        assert_imm_src;
        op = 2'b01; funct = 6'b000000; rd = 0; imm_src_exp = 2'b01; #DELAY;
        assert_imm_src;
        op = 2'b10; funct = 6'b000000; rd = 0; imm_src_exp = 2'b10; #DELAY;
        assert_imm_src;

        // case: reg_src test
        op = 2'b00; funct = 6'b000000; rd = 0; reg_src_exp = 3'b100; #DELAY;
        assert_reg_src;
        op = 2'b01; funct = 6'b000000; rd = 0; reg_src_exp = 3'b010; #DELAY;
        assert_reg_src;

        // case: alu_ctl test
        op = 2'b00; funct = 6'b001000; rd = 0; alu_ctl_exp = 3'b000; #DELAY;
        assert_alu_ctl;
        op = 2'b00; funct = 6'b000100; rd = 0; alu_ctl_exp = 3'b001; #DELAY;
        assert_alu_ctl;
        op = 2'b00; funct = 6'b000000; rd = 0; alu_ctl_exp = 3'b010; #DELAY;
        assert_alu_ctl;
        op = 2'b00; funct = 6'b011000; rd = 0; alu_ctl_exp = 3'b011; #DELAY;
        assert_alu_ctl;
        // ADC
        op = 2'b00; funct = 6'b001010; rd = 0; alu_ctl_exp = 3'b100; #DELAY;
        assert_alu_ctl;


        // case: no_write test
        op = 2'b00; funct = 6'b001000; rd = 0; no_write_exp = 1'b0; #DELAY;
        assert_no_write;
        op = 2'b00; funct = 6'b010101; rd = 0; no_write_exp = 1'b1; #DELAY;
        assert_no_write;

        // case: shift test
        op = 2'b00; funct = 6'b001000; rd = 0; shift_exp = 1'b0; #DELAY;
        assert_shift;
        op = 2'b00; funct = 6'b011011; rd = 0; shift_exp = 1'b1; #DELAY;
        assert_shift;

        $display("test completed");
        $finish;
    end
endmodule
