module CondLogicTestbench;
    parameter HALF_CYCLE = 500;
    parameter DELAY = 100;

    logic clk;
    logic pcs, reg_w, mem_w;
    logic [1:0] flag_w;
    logic [3:0] cond, alu_flags;
    logic pc_src, reg_write, mem_write;
    logic pc_src_exp, reg_write_exp, mem_write_exp;

    CondLogic dut(
    .clk,
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

        $display("test completed");
        $finish;
    end
endmodule
