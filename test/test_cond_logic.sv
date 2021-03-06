module CondLogicTestbench;
    parameter HALF_CYCLE = 500;
    parameter DELAY = 100;

    logic clk, reset;
    logic pcs, reg_w, mem_w;
    logic [1:0] flag_w;
    logic [3:0] cond, alu_flags;
    logic pc_src, reg_write, mem_write;
    logic pc_src_exp, reg_write_exp, mem_write_exp, cond_ex_exp;

    CondLogic dut(
    .clk,
    .reset,
    .pcs,
    .reg_w,
    .mem_w,
    .flag_w,
    .cond,
    .alu_flags,
    .pc_src,
    .reg_write,
    .mem_write
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

    task assert_dut_cond_ex;
        assert (dut.cond_ex === cond_ex_exp) else $error("dut.cond_ex = %b, %b expected", dut.cond_ex, cond_ex_exp);
    endtask

    task show_dut_vars(input string s);
        $display("%s: dut -> cond_ex = %b, flag_write = %b, flags = %b, flag_w = %b, alu_flags = %b, n = %b, z = %b, c = %b , v = %b", s, dut.cond_ex, dut.flag_write, dut.flags, dut.flag_w, dut.alu_flags, dut.n, dut.z, dut.c, dut.v);
    endtask

    task test_cond_check(input logic [3:0] cond_in, alu_flags_in, input logic cond_ex_exp_in, input string testname);
        begin
            // 状態初期化
            reset = 1;
            #DELAY;
            reset = 0;
            #DELAY;

            // 前提条件設定、flag_write = 2'b11にするために1度cond_ex = 1にする
            flag_w = 2'b11;
            cond = 4'b1110;

            // 期待値設定
            cond_ex_exp = cond_ex_exp_in;

            // alu_flagsを条件チェックに反映、alu_flagsは1クロック遅れてdut.flagsに反映される
            alu_flags = alu_flags_in;
            @(posedge clk); #DELAY;

            // 条件チェック、dut.flagsを元にcond_exが決まる
            cond = cond_in;
            # DELAY;

            // 検証
            show_dut_vars(testname);
            assert_dut_cond_ex;
        end
    endtask

    always begin
        clk = 0;
        #HALF_CYCLE;
        clk = 1;
        #HALF_CYCLE;
    end

    initial begin
        // case: pc_src test
        cond = 4'b1110; pcs = 1'b0; pc_src_exp = 1'b0;
        @(posedge clk); #DELAY
        assert_pc_src;
        cond = 4'b1110; pcs = 1'b1; pc_src_exp = 1'b1;
        @(posedge clk); #DELAY
        assert_pc_src;

        // case: reg_write test
        cond = 4'b1110; reg_w = 1'b0; reg_write_exp = 1'b0;
        @(posedge clk); #DELAY
        assert_reg_write;
        cond = 4'b1110; reg_w = 1'b1; reg_write_exp = 1'b1;
        @(posedge clk); #DELAY
        assert_reg_write;

        // case: mem_write test
        cond = 4'b1110; mem_w = 1'b0; mem_write_exp = 1'b0;
        @(posedge clk); #DELAY
        assert_mem_write;
        cond = 4'b1110; mem_w = 1'b1; mem_write_exp = 1'b1;
        @(posedge clk); #DELAY
        assert_mem_write;

        // case: 条件チェック
        // EQ
        test_cond_check(4'b0000, 4'b0100, 1'b1, "EQ");

        // NE
        test_cond_check(4'b0001, 4'b0000, 1'b1, "NE");

        // CS
        test_cond_check(4'b0010, 4'b0010, 1'b1, "CS");

        // CC
        test_cond_check(4'b0011, 4'b0000, 1'b1, "CC");

        // MI
        test_cond_check(4'b0100, 4'b1000, 1'b1, "MI");

        // PL
        test_cond_check(4'b0101, 4'b0000, 1'b1, "PL");

        // VS
        test_cond_check(4'b0110, 4'b0001, 1'b1, "VS");

        // VC
        test_cond_check(4'b0111, 4'b0000, 1'b1, "VC");

        // HI
        test_cond_check(4'b1000, 4'b0010, 1'b1, "HI");

        // LS
        test_cond_check(4'b1001, 4'b0100, 1'b1, "LS-1");
        test_cond_check(4'b1001, 4'b0000, 1'b1, "LS-2");

        // GE
        test_cond_check(4'b1010, 4'b1001, 1'b1, "GE-1");
        test_cond_check(4'b1010, 4'b0000, 1'b1, "GE-2");

        // LT
        test_cond_check(4'b1011, 4'b0001, 1'b1, "LT-1");
        test_cond_check(4'b1011, 4'b1000, 1'b1, "LT-2");

        // GT
        test_cond_check(4'b1100, 4'b1001, 1'b1, "GT-1");
        test_cond_check(4'b1100, 4'b0000, 1'b1, "GT-2");

        // LE
        test_cond_check(4'b1101, 4'b0100, 1'b1, "LE-1");
        test_cond_check(4'b1101, 4'b0001, 1'b1, "LE-2");
        test_cond_check(4'b1101, 4'b1000, 1'b1, "LE-3");

        // AL
        test_cond_check(4'b1110, 4'b1111, 1'b1, "AL");

        $display("test completed");
        $finish;
    end
endmodule