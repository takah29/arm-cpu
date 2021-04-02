module MainDecoderTestbench;
    parameter DELAY = 10;

    logic [1:0] op;
    logic [5:0] funct;
    logic [3:0] instr74;
    logic branch, mem_to_reg, mem_w, alu_src, reg_src, reg_w3, reg_w1, alu_op, post_idx, mult;
    logic [1:0] imm_src;
    logic branch_exp, mem_to_reg_exp, mem_w_exp, alu_src_exp, reg_src_exp, reg_w3_exp, reg_w1_exp, alu_op_exp, post_idx_exp, mult_exp;
    logic [1:0] imm_src_exp;

    MainDecoder dut(
    .op,
    .funct,
    .instr74,
    .branch,
    .mem_to_reg,
    .mem_w,
    .alu_src,
    .reg_w3,
    .reg_w1,
    .alu_op,
    .reg_src,
    .post_idx,
    .mult,
    .imm_src
    );

    task assert_;
        assert (branch === branch_exp) else $error("branch = %b, %b expected", branch, branch_exp);
        assert (mem_to_reg === mem_to_reg_exp) else $error("mem_to_reg = %b, %b expected", mem_to_reg, mem_to_reg_exp);
        assert (mem_w === mem_w_exp) else $error("mem_w = %b, %b expected", mem_w, mem_w_exp);
        assert (alu_src === alu_src_exp) else $error("alu_src = %b, %b expected", alu_src, alu_src_exp);
        assert (imm_src === imm_src_exp) else $error("imm_src = %b, %b expected", imm_src, imm_src_exp);
        assert (reg_w3 === reg_w3_exp) else $error("reg_w3 = %b, %b expected", reg_w3, reg_w3_exp);
        assert (reg_w1 === reg_w1_exp) else $error("reg_w1 = %b, %b expected", reg_w1, reg_w1_exp);
        assert (reg_src === reg_src_exp) else $error("reg_src = %b, %b expected", reg_src, reg_src_exp);
        assert (alu_op === alu_op_exp) else $error("alu_op = %b, %b expected", alu_op, alu_op_exp);
        assert (post_idx === post_idx_exp) else $error("post_idx = %b, %b expected", post_idx, post_idx_exp);
        assert (mult === mult_exp) else $error("mult = %b, %b expected", mult, mult_exp);
    endtask

    task set_exp(input [11:0] controls);
        begin
            {
                branch_exp,
                mem_to_reg_exp,
                mem_w_exp,
                alu_src_exp,
                imm_src_exp,
                reg_w3_exp,
                reg_w1_exp,
                reg_src_exp,
                alu_op_exp,
                post_idx_exp,
                mult_exp
            } = controls;
        end
    endtask

    initial begin
        // case: type DP Reg
        op = 2'b00; funct = 6'b000000; instr74 = 4'b0001; set_exp(12'b0_0_0_0_00_1_0_0_1_0_0); #DELAY;
        assert_;

        // case: type DP Imm
        op = 2'b00; funct = 6'b100000; instr74 = 4'b0000; set_exp(12'b0_0_0_1_00_1_0_0_1_0_0); #DELAY;
        assert_;

        // case: DP Multiply 32-bit
        op = 2'b00; funct = 6'b000000; instr74 = 4'b1001; set_exp(12'b0_0_0_0_00_0_1_0_0_0_1); #DELAY;
        assert_;

        // case: DP Multiply 64-bit
        op = 2'b00; funct = 6'b001000; instr74 = 4'b1001; set_exp(12'b0_0_0_0_00_1_1_0_0_0_1); #DELAY;
        assert_;

        // case: type STR (Imm)
        op = 2'b01; funct = 6'b01XX00; instr74 = 4'b1001; set_exp(12'b0_0_1_1_01_0_0_0_0_0_0); #DELAY;
        assert_;

        // case: type STR (Reg)
        op = 2'b01; funct = 6'b11XX00; instr74 = 4'b0000; set_exp(12'b0_0_1_0_01_0_0_0_0_0_0); #DELAY;
        assert_;

        // case: type STR (Imm, PostIdx)
        op = 2'b01; funct = 6'b00XX00; instr74 = 4'b0000; set_exp(12'b0_0_1_1_01_0_1_0_0_1_0); #DELAY;
        assert_;

        // case: type STR (Reg, PostIdx)
        op = 2'b01; funct = 6'b10XX00; instr74 = 4'b0000; set_exp(12'b0_0_1_0_01_0_1_0_0_1_0); #DELAY;
        assert_;

        // case: type STR (Imm, PreIdx)
        op = 2'b01; funct = 6'b01XX10; instr74 = 4'b0000; set_exp(12'b0_0_1_1_01_0_1_0_0_0_0); #DELAY;
        assert_;

        // case: type STR (Reg, PreIdx)
        op = 2'b01; funct = 6'b11XX10; instr74 = 4'b0000; set_exp(12'b0_0_1_0_01_0_1_0_0_0_0); #DELAY;
        assert_;

        // case: type LDR (Imm)
        op = 2'b01; funct = 6'b01XX01; instr74 = 4'b0000; set_exp(12'b0_1_0_1_01_1_0_0_0_0_0); #DELAY;
        assert_;

        // case: type LDR (Reg)
        op = 2'b01; funct = 6'b11XX01; instr74 = 4'b0000; set_exp(12'b0_1_0_0_01_1_0_0_0_0_0); #DELAY;
        assert_;

        // case: type LDR (Imm, post_idx)
        op = 2'b01; funct = 6'b00XX01; instr74 = 4'b0000; set_exp(12'b0_1_0_1_01_1_1_0_0_1_0); #DELAY;
        assert_;

        // case: type LDR (Reg, post_idx)
        op = 2'b01; funct = 6'b10XX01; instr74 = 4'b0000; set_exp(12'b0_1_0_0_01_1_1_0_0_1_0); #DELAY;
        assert_;

        // case: type LDR (Imm, PreIdx)
        op = 2'b01; funct = 6'b01XX11; instr74 = 4'b0000; set_exp(12'b0_1_0_1_01_1_1_0_0_0_0); #DELAY;
        assert_;

        // case: type LDR (Reg, PreIdx)
        op = 2'b01; funct = 6'b11XX11; instr74 = 4'b0000; set_exp(12'b0_1_0_0_01_1_1_0_0_0_0); #DELAY;
        assert_;

        // case: type B
        op = 2'b10; funct = 6'b100000; instr74 = 4'b0000; set_exp(12'b1_0_0_1_10_0_0_1_0_0_0); #DELAY;
        assert_;

        // case: type BX
        op = 2'b00; funct = 6'b010010; instr74 = 4'b0001; set_exp(12'b1_0_0_0_00_0_0_0_0_0_0); #DELAY;
        assert_;

        $display("test completed");
        $finish;
    end
endmodule
