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
            $display("R%1d = %h", i, dut.data_path.register_file.register_file[i]);
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

    task assert_register_value(input logic [3:0] reg_num, input logic [31:0] exp_value);
        assert (
        dut.data_path.register_file.register_file[reg_num] === exp_value
        ) else $error(
        "R%1d = %h, %h", reg_num, dut.data_path.register_file.register_file[reg_num], exp_value
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

    initial begin
        // 初期化
        reset = 1;
        #DELAY;
        reset = 0;
        #DELAY;
        assert_pc(0);

        // case: LDR
        // LDR R0, [R14] (データメモリがないのでR14はつかわれない)
        instr = 32'b1110_01_000001_1110_0000_000000000000; read_data = 32'hffffffff;
        @(posedge clk); #DELAY;
        assert_pc(4);
        assert_register_value(0, 32'hffffffff);

        // LDR R1, [R14]
        instr = 32'b1110_01_000001_1110_0001_000000000000; read_data = 32'hff;
        @(posedge clk); #DELAY;
        assert_pc(8);
        assert_register_value(1, 32'hff);

        // case: STR
        // STR R0, [R1]
        instr = 32'b1110_01_000000_0001_0000_000000000000;
        @(posedge clk); #DELAY;
        assert_pc(12);
        assert_alu_result(32'hff);
        assert_write_data(32'hffffffff);
        assert_mem_write(1);

        // ADD R2, R1, R1
        instr = 32'b1110_00_001000_0001_0010_000000000001;
        @(posedge clk); #DELAY;
        assert_pc(16);
        assert_alu_result(32'h1fe);
        assert_register_value(2, 32'h1fe);

        // SUB R3, R2, R1
        instr = 32'b1110_00_000100_0010_0011_000000000001;
        @(posedge clk); #DELAY;
        assert_pc(20);
        assert_alu_result(32'hff);
        assert_register_value(3, 32'hff);

        // AND R4, R3, R2
        instr = 32'b1110_00_000000_0011_0100_000000000010;
        @(posedge clk); #DELAY;
        assert_pc(24);
        assert_alu_result(32'hfe);
        assert_register_value(4, 32'hfe);

        // ORR R5, R3, R2
        instr = 32'b1110_00_011000_0011_0101_000000000010;
        @(posedge clk); #DELAY;
        assert_pc(28);
        assert_alu_result(32'h1ff);
        assert_register_value(5, 32'h1ff);

        // CMP R1, R3
        instr = 32'b1110_00_010101_0001_0000_000000000011;
        @(posedge clk); #DELAY;
        assert_pc(32);
        assert_alu_result(32'h0);
        assert (dut.data_path.alu.z === 1'b1);

        $display("test completed");
        $finish;
    end
endmodule
