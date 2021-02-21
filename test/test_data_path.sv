module DataPathTestbench();
    parameter HALF_CYCLE = 500;
    parameter STB = 100;

    logic clk, reset;
    logic reg_write;
    logic [31:0] instr, read_data;
    logic [1:0] alu_ctl;
    logic [31:0] pc, write_data, alu_result;
    logic [31:0] pc_exp, write_data_exp, alu_result_exp;

    DataPath dut(.clk, .reset, .reg_write, .instr, .read_data, .alu_ctl, .pc, .write_data, .alu_result);

    task assert_;
        assert (write_data === write_data_exp) else $error("write_data = %h, %h expected", write_data, write_data_exp);
        assert (alu_result === alu_result_exp) else $error("alu_result = %h, %h expected", alu_result, alu_result_exp);
    endtask

    always begin
        clk = 0;
        #HALF_CYCLE;
        clk = 1;
        #HALF_CYCLE;
    end

    initial begin
        reset = 0;
        alu_ctl = 0;

        // case: r1に15を設定、r11にアドレス32を設定、r1の値をアドレスr11に書き込む
        // ldr r1, [r0] （read_dataで設定するのでinstrのr11のところは何でもいい）
        instr = 32'b11100101100100000001000000000000; read_data = 15; reg_write = 1;
        @(posedge clk)
        #STB;
        // ldr r11, [r0] （read_dataで設定するのでinstrのr11のところは何でもいい）
        instr = 32'b11100101100100001011000000000000; read_data = 32; reg_write = 1;
        @(posedge clk)
        #STB;
        // str r1. [r11]
        instr = 32'b11100101100010110001000000000000; read_data = 0; reg_write = 0;
        @(posedge clk)
        #STB;
        write_data_exp = 15; alu_result_exp = 32;
        assert_;

        $display("test completed");
        $finish;
    end
endmodule
