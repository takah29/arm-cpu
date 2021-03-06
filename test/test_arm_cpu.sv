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

    task show_regs;
        for (int i = 0; i < 15; i++) begin
            $display("R%1d = %h", i, dut.data_path.register_file.register_file[i]);
        end
        $display("R15 = %h", dut.data_path.register_file.r15);
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
        instr = 32'b11100100000111100000000000000000; read_data = 32'hffffffff;
        @(posedge clk); #DELAY;
        assert_pc(4);
        assert_register_value(0, 32'hffffffff);

        // LDR R1, [R14]
        instr = 32'b11100100000111100001000000000000; read_data = 32'hff;
        @(posedge clk); #DELAY;
        assert_pc(8);
        assert_register_value(1, 32'hff);

        // case: STR
        // STR R0, [R1]
        instr = 32'b11100100000000010000000000000000;
        @(posedge clk); #DELAY;
        assert_pc(12);
        assert_alu_result(32'hff);
        assert_write_data(32'hffffffff);
        assert_mem_write(1);

        $display("test completed");
        $finish;
    end
endmodule
