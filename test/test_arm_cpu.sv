module ArmCpuTestbench;
    parameter HALF_CYCLE = 500;
    parameter DELAY = 100;

    logic clk, reset;
    logic [31:0] instr, read_data;
    logic mem_write;
    logic [31:0] pc, write_data, data_memory_addr;

    ArmCpu dut(
    .clk,
    .reset,
    .instr,
    .read_data,
    .mem_write,
    .pc,
    .write_data,
    .data_memory_addr
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

    task assert_data_memory_addr(input logic [31:0] data_memory_addr_exp);
        assert (data_memory_addr === data_memory_addr_exp) else $error("data_memory_addr = %b, %b expected", data_memory_addr, data_memory_addr_exp);
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

    // シミュレーション結果出力
    // initial begin
    //   // 波形データ出力
    //   $dumpfile("wave.vcd");
    //   // 全てのポートを波形データに出力
    //   $dumpvars(0, dut);
    // end

    initial begin
        // case: Memory
        // LDR R13, [R10]
        reset_; set_regs; #DELAY
        instr = 32'b1110_01_011001_1010_1101_00000_00_0_0000; read_data = 32'hffffffff;
        #DELAY
        assert_data_memory_addr(32'h000000ff);
        @(posedge clk); #DELAY;
        assert_register_value(13, 32'hffffffff);

        // LDR R14, [R6, #3]
        reset_; set_regs; #DELAY
        instr = 32'b1110_01_011001_0110_1110_000000000011; read_data = 32'hffffffff;
        #DELAY
        assert_data_memory_addr(10);
        @(posedge clk); #DELAY;
        assert_register_value(14, 32'hffffffff);

        // LDR R14, [R3, R2]
        reset_; set_regs; #DELAY
        instr = 32'b1110_01_111001_0011_1110_00000_00_0_0010; read_data = 32'hffffffff;
        #DELAY
        assert_data_memory_addr(1010);
        @(posedge clk); #DELAY;
        assert_register_value(14, 32'hffffffff);

        // LDR R14, [R3], R2
        reset_; set_regs; #DELAY
        instr = 32'b1110_01_101001_0011_1110_00000_00_0_0010; read_data = 32'hffff0000;
        #DELAY
        assert_data_memory_addr(1000);
        @(posedge clk); #DELAY;
        assert_register_value(14, 32'hffff0000);
        assert_register_value(3, 1010);

        // LDR R14, [R3, R2, LSL #2]
        reset_; set_regs; #DELAY
        instr = 32'b1110_01_111001_0011_1110_00010_00_0_0010; read_data = 32'hffffffff;
        #DELAY
        assert_data_memory_addr(1040);
        @(posedge clk); #DELAY;
        assert_register_value(14, 32'hffffffff);

        // STR R6, [R10]
        reset_; set_regs; #DELAY
        instr = 32'b1110_01_011000_1010_0110_000000000000;
        #DELAY;
        assert_data_memory_addr(32'hff);
        assert_write_data(7);
        assert_mem_write(1);

        // STR R6, [R4, #7]
        reset_; set_regs; #DELAY
        instr = 32'b1110_01_011000_0100_0110_000000000111;
        #DELAY;
        assert_data_memory_addr(10);
        assert_write_data(7);
        assert_mem_write(1);

        // STR R6, [R3, R2]
        reset_; set_regs; #DELAY
        instr = 32'b1110_01_111000_0011_0110_00000_00_0_0010;
        #DELAY;
        assert_data_memory_addr(1010);
        assert_write_data(7);
        assert_mem_write(1);

        // STR R6, [R3, R2, LSL #3]
        reset_; set_regs; #DELAY
        instr = 32'b1110_01_111000_0011_0110_00011_00_0_0010;
        #DELAY;
        assert_data_memory_addr(1080);
        assert_write_data(7);
        assert_mem_write(1);

        // case: DP Reg
        // ADD R13, R4, R5
        reset_; set_regs; #DELAY
        instr = 32'b1110_00_001000_0100_1101_00000000_0101;
        #DELAY;
        assert_data_memory_addr(8);
        @(posedge clk); #DELAY;
        assert_register_value(13, 8);

        // ADD R13, R4, R1, LSL #2
        reset_; set_regs; #DELAY
        instr = 32'b1110_00_001000_0100_1101_00010_00_0_0001;
        #DELAY;
        assert_data_memory_addr(7);
        @(posedge clk); #DELAY;
        assert_register_value(13, 7);

        // ADD R14, R3, R2, LSL R4
        reset_; set_regs; #DELAY
        instr = 32'b1110_00_001000_0011_1110_0100_0_00_1_0010;
        #DELAY;
        assert_data_memory_addr(1080);
        @(posedge clk); #DELAY;
        assert_register_value(14, 1080);

        // SUB R13, R6, R5
        reset_; set_regs; #DELAY
        instr = 32'b1110_00_000100_0110_1101_00000000_0101;
        #DELAY;
        assert_data_memory_addr(2);
        @(posedge clk); #DELAY;
        assert_register_value(13, 2);

        // AND R14, R7, R8
        reset_; set_regs; #DELAY
        instr = 32'b1110_00_000000_0111_1110_00000000_1000;
        #DELAY;
        assert_data_memory_addr(32'h00000000);
        @(posedge clk); #DELAY;
        assert_register_value(14, 32'h00000000);

        // ORR R14, R7, R8
        reset_; set_regs; #DELAY
        instr = 32'b1110_00_011000_0111_1110_00000000_1000;
        #DELAY;
        assert_data_memory_addr(32'hffffffff);
        @(posedge clk); #DELAY;
        assert_register_value(14, 32'hffffffff);

        // EOR R14, R10, R12
        reset_; set_regs; #DELAY
        instr = 32'b1110_00_000010_1010_1110_00000000_1100;
        #DELAY;
        assert_data_memory_addr(32'h00ffff00);
        @(posedge clk); #DELAY;
        assert_register_value(14, 32'h00ffff00);

        // ADC (まずADDを実行してcarryフラグを上げる)
        // ADD R13, R1, R9
        reset_; set_regs; #DELAY
        instr = 32'b1110_00_001001_0001_1101_00000000_1001;
        #DELAY;
        assert_data_memory_addr(0);
        @(posedge clk); #DELAY;
        assert_register_value(13, 0);
        // ADC R14, R0, R9
        instr = 32'b1110_00_001010_0000_1110_00000000_1001;
        #DELAY;
        assert_data_memory_addr(0);
        @(posedge clk); #DELAY;
        assert_register_value(14, 0);

        // SBC (まずADDを実行してcarryフラグを上げる)
        // ADD R13, R1, R9
        reset_; set_regs; #DELAY
        instr = 32'b1110_00_001001_0001_1101_00000000_1001;
        #DELAY;
        assert_data_memory_addr(0);
        @(posedge clk); #DELAY;
        assert_register_value(13, 0);
        // SBC R13, R6, R5
        instr = 32'b1110_00_001100_0110_1101_00000000_0101;
        #DELAY;
        assert_data_memory_addr(2);
        @(posedge clk); #DELAY;
        assert_register_value(13, 2);

        // SBC R13, R6, R5 (carryフラグを上げない)
        reset_; set_regs; #DELAY
        instr = 32'b1110_00_001100_0110_1101_00000000_0101;
        #DELAY;
        assert_data_memory_addr(1);
        @(posedge clk); #DELAY;
        assert_register_value(13, 1);

        // RSB R13, R5, R6
        reset_; set_regs; #DELAY
        instr = 32'b1110_00_000110_0101_1101_00000000_0110;
        #DELAY;
        assert_data_memory_addr(2);
        @(posedge clk); #DELAY;
        assert_register_value(13, 2);

        // RSC (まずADDを実行してcarryフラグを上げる)
        // ADD R13, R1, R9
        reset_; set_regs; #DELAY
        instr = 32'b1110_00_001001_0001_1101_00000000_1001;
        #DELAY;
        assert_data_memory_addr(0);
        @(posedge clk); #DELAY;
        assert_register_value(13, 0);
        // RSC R13, R5, R6
        instr = 32'b1110_00_001110_0101_1101_00000000_0110;
        #DELAY;
        assert_data_memory_addr(2);
        @(posedge clk); #DELAY;
        assert_register_value(13, 2);

        // RSC R13, R5, R6 (carryフラグを上げない)
        reset_; set_regs; #DELAY
        instr = 32'b1110_00_001110_0101_1101_00000000_0110;
        #DELAY;
        assert_data_memory_addr(1);
        @(posedge clk); #DELAY;
        assert_register_value(13, 1);

        // BIC R13, R9, R12
        reset_; set_regs; #DELAY
        instr = 32'b1110_00_011100_1001_1101_00000000_1100;
        #DELAY;
        assert_data_memory_addr(32'hff000000);
        @(posedge clk); #DELAY;
        assert_register_value(13, 32'hff000000);

        // CMP R5, R5
        reset_; set_regs; #DELAY
        instr = 32'b1110_00_010101_0101_0000_00000000_0101;
        #DELAY;
        assert_data_memory_addr(32'h0);
        assert (dut.data_path.alu.z === 1'b1);

        // CMP R6, R5
        reset_; set_regs; #DELAY
        instr = 32'b1110_00_010101_0110_0000_00000000_0101;
        #DELAY;
        assert_data_memory_addr(2);
        assert (dut.data_path.alu.z === 1'b0);

        // TEQ R5, R5
        reset_; set_regs; #DELAY
        instr = 32'b1110_00_010011_0101_0000_00000000_0101;
        #DELAY;
        assert_data_memory_addr(0);
        assert (dut.data_path.alu.z === 1'b1);

        // CMN R1, R9
        reset_; set_regs; #DELAY
        instr = 32'b1110_00_010111_0001_0000_00000000_1001;
        #DELAY;
        assert_data_memory_addr(32'h0);
        assert (dut.data_path.alu.z === 1'b1);

        // CMN R1, R2
        reset_; set_regs; #DELAY
        instr = 32'b1110_00_010111_0001_0000_00000000_0010;
        #DELAY;
        assert_data_memory_addr(11);
        assert (dut.data_path.alu.z === 1'b0);

        // TST R7, R8
        reset_; set_regs; #DELAY
        instr = 32'b1110_00_010001_0111_0000_00000000_1000;
        #DELAY;
        assert_data_memory_addr(0);
        assert (dut.data_path.alu.z === 1'b1);

        // LSL R13, R2, #2
        reset_; set_regs; #DELAY
        instr = 32'b1110_00_011010_0000_1101_00010_00_0_0010;
        #DELAY;
        assert_data_memory_addr(40);
        @(posedge clk); #DELAY;
        assert_register_value(13, 40);

        // LSL R13, R2, R4
        reset_; set_regs; #DELAY
        instr = 32'b1110_00_011010_0000_1101_0100_0_00_1_0010;
        #DELAY;
        assert_data_memory_addr(80);
        @(posedge clk); #DELAY;
        assert_register_value(13, 80);

        // LSR R13, R3, #2
        reset_; set_regs; #DELAY
        instr = 32'b1110_00_011010_0000_1101_00010_01_0_0011;
        #DELAY;
        assert_data_memory_addr(250);
        @(posedge clk); #DELAY;
        assert_register_value(13, 250);

        // LSR R13, R3, R4
        reset_; set_regs; #DELAY
        instr = 32'b1110_00_011010_0000_1101_0100_0_01_1_0011;
        #DELAY;
        assert_data_memory_addr(125);
        @(posedge clk); #DELAY;
        assert_register_value(13, 125);

        // ASR R13, R7, #31
        reset_; set_regs; #DELAY
        instr = 32'b1110_00_011010_0000_1101_11111_10_0_0111;
        #DELAY;
        assert_data_memory_addr(32'hffffffff);
        @(posedge clk); #DELAY;
        assert_register_value(13, 32'hffffffff);

        // ASR R13, R7, R4
        reset_; set_regs; #DELAY
        instr = 32'b1110_00_011010_0000_1101_0100_0_10_1_0111;
        #DELAY;
        assert_data_memory_addr(32'hf0000000);
        @(posedge clk); #DELAY;
        assert_register_value(13, 32'hf0000000);

        // ROR R13, R8, #4
        reset_; set_regs; #DELAY
        instr = 32'b1110_00_011010_0000_1101_00100_11_0_1000;
        #DELAY;
        assert_data_memory_addr(32'hf7ffffff);
        @(posedge clk); #DELAY;
        assert_register_value(13, 32'hf7ffffff);

        // ROR R13, R8, R4
        reset_; set_regs; #DELAY
        instr = 32'b1110_00_011010_0000_1101_0100_0_11_1_1000;
        #DELAY;
        assert_data_memory_addr(32'hefffffff);
        @(posedge clk); #DELAY;
        assert_register_value(13, 32'hefffffff);

        // MOV R13, R3 (シフト命令のシフト量が0の場合と等価)
        reset_; set_regs; #DELAY
        instr = 32'b1110_00_011010_0000_1101_00000_00_0_0011;
        #DELAY;
        assert_data_memory_addr(1000);
        @(posedge clk); #DELAY;
        assert_register_value(13, 1000);

        // MVN R13, R11
        reset_; set_regs; #DELAY
        instr = 32'b1110_00_011110_0000_1101_00000_00_0_1011;
        #DELAY;
        assert_data_memory_addr(32'hffff0000);
        @(posedge clk); #DELAY;
        assert_register_value(13, 32'hffff0000);

        // case: DP Imm
        // ADD R13, R2, #42
        reset_; set_regs; #DELAY
        instr = 32'b1110_00_101000_0010_1101_0000_00101010;
        #DELAY;
        assert_data_memory_addr(52);
        @(posedge clk); #DELAY;
        assert_register_value(13, 52);

        // SUB R13, R11, #0xFF0 (右回転テスト)
        reset_; set_regs; #DELAY
        instr = 32'b1110_00_100100_1011_1101_1110_11111111;
        #DELAY;
        assert_data_memory_addr(32'h0000f00f);
        @(posedge clk); #DELAY;
        assert_register_value(13, 32'h0000f00f);

        // AND R14, R11, #0xFF00
        reset_; set_regs; #DELAY
        instr = 32'b1110_00_100000_1011_1110_1100_11111111;
        #DELAY;
        assert_data_memory_addr(32'h0000ff00);
        @(posedge clk); #DELAY;
        assert_register_value(14, 32'h0000ff00);

        // ORR R14, R6, #0xF8
        reset_; set_regs; #DELAY
        instr = 32'b1110_00_111000_0110_1110_0000_11111000;
        #DELAY;
        assert_data_memory_addr(32'h000000ff);
        @(posedge clk); #DELAY;
        assert_register_value(14, 32'h000000ff);

        // EOR R14, R10, #0xFF00
        reset_; set_regs; #DELAY
        instr = 32'b1110_00_100010_1010_1110_1100_11111111;
        #DELAY;
        assert_data_memory_addr(32'h0000ffff);
        @(posedge clk); #DELAY;
        assert_register_value(14, 32'h0000ffff);

        // ADC (まずADDを実行してcarryフラグを上げる)
        // ADD R13, R1, R9
        reset_; set_regs; #DELAY
        instr = 32'b1110_00_001001_0001_1101_00000000_1001;
        #DELAY;
        assert_data_memory_addr(0);
        @(posedge clk); #DELAY;
        assert_register_value(13, 0);
        // ADC R14, R2, #2
        instr = 32'b1110_00_101010_0010_1110_0000_00000010;
        #DELAY;
        assert_data_memory_addr(13);
        @(posedge clk); #DELAY;
        assert_register_value(14, 13);

        // SBC (まずADDを実行してcarryフラグを上げる)
        // ADD R13, R1, R9
        reset_; set_regs; #DELAY
        instr = 32'b1110_00_001001_0001_1101_00000000_1001;
        #DELAY;
        assert_data_memory_addr(0);
        @(posedge clk); #DELAY;
        assert_register_value(13, 0);
        // SBC R13, R2, #2
        instr = 32'b1110_00_101100_0010_1101_0000_00000010;
        #DELAY;
        assert_data_memory_addr(8);
        @(posedge clk); #DELAY;
        assert_register_value(13, 8);

        // SBC R13, R2, #2 (carryフラグを上げない)
        reset_; set_regs; #DELAY
        instr = 32'b1110_00_101100_0010_1101_0000_00000010;
        #DELAY;
        assert_data_memory_addr(7);
        @(posedge clk); #DELAY;
        assert_register_value(13, 7);

        // RSB R13, R6, #7
        reset_; set_regs; #DELAY
        instr = 32'b1110_00_100110_0110_1101_0000_00000111;
        #DELAY;
        assert_data_memory_addr(0);
        @(posedge clk); #DELAY;
        assert_register_value(13, 0);

        // RSC (まずADDを実行してcarryフラグを上げる)
        // ADD R13, R1, R9
        reset_; set_regs; #DELAY
        instr = 32'b1110_00_001001_0001_1101_00000000_1001;
        #DELAY;
        assert_data_memory_addr(0);
        @(posedge clk); #DELAY;
        assert_register_value(13, 0);
        // RSC R13, R6, #7
        instr = 32'b1110_00_101110_0110_1101_0000_00000111;
        #DELAY;
        assert_data_memory_addr(0);
        @(posedge clk); #DELAY;
        assert_register_value(13, 0);

        // RSC R13, R5, R6 (carryフラグを上げない)
        reset_; set_regs; #DELAY
        instr = 32'b1110_00_101110_0110_1101_0000_00000111;
        #DELAY;
        assert_data_memory_addr(32'hffffffff);
        @(posedge clk); #DELAY;
        assert_register_value(13, 32'hffffffff);

        // BIC R13, R9, #0xFF00
        reset_; set_regs; #DELAY
        instr = 32'b1110_00_111100_1001_1101_1100_11111111;
        #DELAY;
        assert_data_memory_addr(32'hffff00ff);
        @(posedge clk); #DELAY;
        assert_register_value(13, 32'hffff00ff);

        // CMP R5, #5
        reset_; set_regs; #DELAY
        instr = 32'b1110_00_110101_0101_0000_0000_00000101;
        #DELAY;
        assert_data_memory_addr(32'h0);
        assert (dut.data_path.alu.z === 1'b1);

        // case: Branch
        // B Label
        reset_; set_regs; #DELAY
        instr = 32'b1110_10_10_000000000000000000001111;
        #DELAY;
        assert_data_memory_addr(32'h44);
        assert_pc(0);
        @(posedge clk); #DELAY;
        assert_pc(32'h44);

        $display("test completed");
        $finish;
    end
endmodule
