module DataPathTestbench();
    parameter HALF_CYCLE = 500;
    parameter STB = 100;

    logic clk, reset;
    logic pc_src, reg_write, mem_to_reg, alu_src, shift;
    logic [31:0] instr, read_data;
    logic [1:0] imm_src, alu_ctl, reg_src;
    logic [31:0] pc, write_data, data_memory_addr;
    logic [31:0] pc_exp, write_data_exp, data_memory_addr_exp;

    DataPath dut(.clk, .reset, .pc_src, .imm_src, .reg_write, .mem_to_reg, .alu_src, .shift, .instr, .read_data, .alu_ctl, .reg_src, .pc, .write_data, .data_memory_addr);

    task assert_out;
        assert (write_data === write_data_exp) else $error("write_data = %h, %h expected", write_data, write_data_exp);
        assert (data_memory_addr === data_memory_addr_exp) else $error("data_memory_addr = %h, %h expected", data_memory_addr, data_memory_addr_exp);
    endtask

    always begin
        clk = 0;
        #HALF_CYCLE;
        clk = 1;
        #HALF_CYCLE;
    end

    initial begin
        reset = '0;

        // メモリ命令
        alu_ctl = '0;
        imm_src = 2'b01;
        mem_to_reg = '1;
        reg_src = 2'b10;
        alu_src = '1;
        shift = 1'b0;

        // case1: r1に15を設定、r11にアドレス32を設定、r1の値をアドレスr11に書き込む
        // ldr r1, [r0] （read_dataで設定するのでinstrのr0のところは何でもいい）
        instr = 32'b11100101100100000001000000000000; read_data = 15; reg_write = 1;
        @(posedge clk);
        #STB;
        assert (dut.register_file.reg_file[1] === read_data);

        // ldr r11, [r0] （read_dataで設定するのでinstrのr0のところは何でもいい）
        instr = 32'b11100101100100001011000000000000; read_data = 32; reg_write = 1;
        @(posedge clk);
        #STB;
        assert (dut.register_file.reg_file[11] === read_data);

        // str r1. [r11]
        instr = 32'b11100101100010110001000000000000; read_data = 0; reg_write = 0;
        @(posedge clk);
        #STB;
        write_data_exp = 15; data_memory_addr_exp = 32;
        assert_out;

        // case2: プログラムカウンタに128を設定して、r15に 128 + 8 = 136 が設定されることを確認
        instr = 32'b11100101100011110000000000000000; read_data = 128; reg_write = 0; pc_src = 1;
        @(posedge clk);
        #STB;
        assert (dut.register_file.read_data1 === 136);

        $display("test completed");
        $finish;
    end
endmodule
