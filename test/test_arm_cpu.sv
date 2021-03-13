module ArmCpuTestbench;
    parameter HALF_CYCLE = 500;
    parameter DELAY = 100;

    logic clk, reset;
    logic [31:0] instr, read_data;
    logic mem_write;
    logic [31:0] pc, write_data, alu_result;

    ArmCpu dut(
    .clk,
    .reset,
    .instr,
    .read_data,
    .mem_write,
    .pc,
    .write_data,
    .alu_result
    );

    task p(input int x);
        $display("%1b", x);
    endtask

    task show_regs;
        for (int i = 0; i < 15; i++) begin
            $display("R%1d = %h", i, dut.data_path.register_file.reg_file[i]);
        end
        $display("R15 = %h", dut.data_path.register_file.r15);
    endtask

    // テスト用初期レジスタ値設定
    task set_regs;
        // 計算用
        dut.data_path.register_file.reg_file[0] = 0;
        dut.data_path.register_file.reg_file[1] = 1;
        dut.data_path.register_file.reg_file[2] = 10;
        dut.data_path.register_file.reg_file[3] = 1000;
        dut.data_path.register_file.reg_file[4] = 3;
        dut.data_path.register_file.reg_file[5] = 5;
        dut.data_path.register_file.reg_file[6] = 7;
        dut.data_path.register_file.reg_file[7] = 32'h80000000;
        dut.data_path.register_file.reg_file[8] = 32'h7fffffff;
        dut.data_path.register_file.reg_file[9] = 32'hffffffff;

        // アドレス用
        dut.data_path.register_file.reg_file[10] = 32'h000000ff;
        dut.data_path.register_file.reg_file[11] = 32'h0000ffff;
        dut.data_path.register_file.reg_file[12] = 32'h00ffffff;

        // 演算結果保存用
        dut.data_path.register_file.reg_file[13] = 32'h0f0f0f0f;
        dut.data_path.register_file.reg_file[14] = 32'h0f0f0f0f;
    endtask

    task show_flags;
        $display("pc_src = %b", dut.controller.pc_src);
        $display("mem_to_reg = %b", dut.controller.mem_to_reg);
        $display("mem_write = %b", dut.controller.mem_write);
        $display("alu_ctl = %b", dut.controller.alu_ctl);
        $display("alu_src = %b", dut.controller.alu_src);
        $display("imm_src = %b", dut.controller.imm_src);
        $display("reg_write = %b", dut.controller.reg_write);
        $display("reg_src = %b", dut.controller.reg_src);
    endtask

    task reset_;
        @(negedge clk);
        reset = 1;
        #DELAY;
        reset = 0;
        #DELAY;
        assert_pc(0);
    endtask

    task assert_register_value(input logic [3:0] reg_num, input logic [31:0] exp_value);
        assert (
        dut.data_path.register_file.reg_file[reg_num] === exp_value
        ) else $error(
        "R%1d = %h, %h expected", reg_num, dut.data_path.register_file.reg_file[reg_num], exp_value
        );
    endtask

    task assert_pc(input logic [31:0] pc_exp);
        assert (pc === pc_exp) else $error("pc = %b, %b expected", pc, pc_exp);
    endtask

    task assert_alu_result(input logic [31:0] alu_result_exp);
        assert (alu_result === alu_result_exp) else $error("alu_result = %b, %b expected", alu_result, alu_result_exp);
    endtask

    task assert_write_data(input logic [31:0] write_data_exp);
        assert (write_data === write_data_exp) else $error("write_data = %b, %b expected", write_data, write_data_exp);
    endtask

    task assert_mem_write(input logic mem_write_exp);
        assert (mem_write === mem_write_exp) else $error("mem_write = %b, %b expected", mem_write, mem_write_exp);
    endtask

    always begin
        clk = 0;
        #HALF_CYCLE;
        clk = 1;
        #HALF_CYCLE;
    end

    // シミュレーション設定
    // initial begin
    //   // 波形データ出力
    //   $dumpfile("wave.vcd");
    //   // 全てのポートを波形データに出力
    //   $dumpvars(0, dut);
    // end

    initial begin
        // case: LDR
        // LDR R13, [R0] (データメモリがないのでR14はつかわれない)
        reset_; set_regs; #DELAY
        instr = 32'b1110_01_000001_0000_1101_000000000000; read_data = 32'hffffffff;
        @(posedge clk); #DELAY;
        assert_register_value(13, 32'hffffffff);

        // LDR R14, [R0]
        reset_; set_regs; #DELAY
        instr = 32'b1110_01_000001_0000_1110_000000000000; read_data = 32'hff;
        @(posedge clk); #DELAY;
        assert_register_value(14, 32'hff);

        // case: STR
        // STR R6, [R10]
        reset_; set_regs; #DELAY
        instr = 32'b1110_01_000000_1010_0110_000000000000;
        #DELAY;
        assert_alu_result(32'hff);
        assert_write_data(7);
        assert_mem_write(1);

        // case: DP Reg
        // ADD R13, R4, R5
        reset_; set_regs; #DELAY
        instr = 32'b1110_00_001000_0100_1101_00000000_0101;
        #DELAY;
        assert_alu_result(8);
        @(posedge clk); #DELAY;
        assert_register_value(13, 8);

        // ADD R13, R4, R1, LSL #2
        reset_; set_regs; #DELAY
        instr = 32'b1110_00_001000_0100_1101_00010_00_0_0001;
        #DELAY;
        assert_alu_result(7);
        @(posedge clk); #DELAY;
        assert_register_value(13, 7);

        // SUB R13, R6, R5
        reset_; set_regs; #DELAY
        instr = 32'b1110_00_000100_0110_1101_00000000_0101;
        #DELAY;
        assert_alu_result(2);
        @(posedge clk); #DELAY;
        assert_register_value(13, 2);

        // AND R14, R7, R8
        reset_; set_regs; #DELAY
        instr = 32'b1110_00_000000_0111_1110_00000000_1000;
        #DELAY;
        assert_alu_result(32'h00000000);
        @(posedge clk); #DELAY;
        assert_register_value(14, 32'h00000000);

        // ORR R14, R7, R8
        reset_; set_regs; #DELAY
        instr = 32'b1110_00_011000_0111_1110_00000000_1000;
        #DELAY;
        assert_alu_result(32'hffffffff);
        @(posedge clk); #DELAY;
        assert_register_value(14, 32'hffffffff);

        // CMP R5, R5
        reset_; set_regs; #DELAY
        instr = 32'b1110_00_010101_0101_0000_00000000_0101;
        #DELAY;
        assert_alu_result(32'h0);
        assert (dut.data_path.alu.z === 1'b1);

        // CMP R6, R5
        reset_; set_regs; #DELAY
        instr = 32'b1110_00_010101_0110_0000_00000000_0101;
        #DELAY;
        assert_alu_result(2);
        assert (dut.data_path.alu.z === 1'b0);

        // case: Branch
        // B Label
        reset_; set_regs; #DELAY
        instr = 32'b1110_10_10_000000000000000000001111;
        #DELAY;
        assert_alu_result(32'h44);
        assert_pc(0);
        @(posedge clk); #DELAY;
        assert_pc(32'h44);



        $display("test completed");
        $finish;
    end
endmodule
