module MainDecoderTestbench;
    parameter DELAY = 10;

    logic [1:0] op;
    logic funct_5, funct_0;
    logic branch, mem_to_reg, mem_w, alu_src, reg_w, alu_op;
    logic [1:0] imm_src, reg_src;
    logic branch_exp, mem_to_reg_exp, mem_w_exp, alu_src_exp, reg_w_exp, alu_op_exp;
    logic [1:0] imm_src_exp, reg_src_exp;

    MainDecoder dut(
    .op,
    .funct_5,
    .funct_0,
    .branch,
    .mem_to_reg,
    .mem_w,
    .alu_src,
    .reg_w,
    .alu_op,
    .imm_src,
    .reg_src
    );

    task assert_;
        assert (branch === branch_exp) else $error("branch = %b, %b expected", branch, branch_exp);
        assert (mem_to_reg === mem_to_reg_exp) else $error("mem_to_reg = %b, %b expected", mem_to_reg, mem_to_reg_exp);
        assert (mem_w === mem_w_exp) else $error("mem_w = %b, %b expected", mem_w, mem_w_exp);
        assert (alu_src === alu_src_exp) else $error("alu_src = %b, %b expected", alu_src, alu_src_exp);
        assert (imm_src === imm_src_exp) else $error("imm_src = %b, %b expected", imm_src, imm_src_exp);
        assert (reg_w === reg_w_exp) else $error("reg_w = %b, %b expected", reg_w, reg_w_exp);
        assert (reg_src === reg_src_exp) else $error("reg_src = %b, %b expected", reg_src, reg_src_exp);
        assert (alu_op === alu_op_exp) else $error("alu_op = %b, %b expected", alu_op, alu_op_exp);
    endtask

    task set_exp(input [9:0] controls);
        begin
            {
                branch_exp,
                mem_to_reg_exp,
                mem_w_exp,
                alu_src_exp,
                imm_src_exp,
                reg_w_exp,
                reg_src_exp,
                alu_op_exp
            } = controls;
        end
    endtask

    initial begin
        // case1: type DP Reg
        op = 2'b00; funct_5 = '0; set_exp(10'b0000001001); #DELAY;
        assert_;

        // case2: type DP Imm
        op = 2'b00; funct_5 = '1; set_exp(10'b0001001001); #DELAY;
        assert_;

        // case3: type STR
        op = 2'b01; funct_0 = '0; set_exp(10'b0011010100); #DELAY;
        assert_;

        // case4: type LDR
        op = 2'b01; funct_0 = '1; set_exp(10'b0101011000); #DELAY;
        assert_;

        // case5: type B
        op = 2'b10; set_exp(10'b1001100010); #DELAY;
        assert_;

        $display("test completed");
        $finish;
    end
endmodule