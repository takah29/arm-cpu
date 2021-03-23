module RegisterFileTestbench();
    parameter HALF_CYCLE = 500;
    parameter STB = 100;

    logic clk, reset, write_enable3;
    logic [3:0] read_reg_addr1, read_reg_addr2, write_reg_addr3, read_reg_addrs;
    logic [31:0] write_data3, r15;
    logic [31:0] read_data1, read_data2, read_datas, rd1_expected, rd2_expected, rds_expected;

    RegisterFile dut(
    .clk,
    .reset,
    .write_enable3,
    .read_reg_addr1,
    .read_reg_addr2,
    .write_reg_addr3,
    .read_reg_addrs,
    .write_data3,
    .r15,
    .read_data1,
    .read_data2,
    .read_datas
    );

    task reset_;
        // initialize
        for (int i = 0; i < 15; i++) begin
            @(posedge clk) write_reg_addr3 = i; write_enable3 = 1; write_data3 = 0; #STB;
        end
    endtask

    task assert_;
        assert (read_data1 === rd1_expected) else $error("read_data1 = %h, %h expected", read_data1, rd1_expected);
        assert (read_data2 === rd2_expected) else $error("read_data2 = %h, %h expected", read_data2, rd2_expected);
        assert (read_datas === rds_expected) else $error("read_datas = %h, %h expected", read_datas, rds_expected);
    endtask

    always begin
        clk = 0;
        #HALF_CYCLE;
        clk = 1;
        #HALF_CYCLE;
    end

    initial begin
        reset_;

        // case1
        @(posedge clk) write_enable3 = 0; write_data3 = 0;
        read_reg_addr1 = 0; rd1_expected = 0;
        read_reg_addr2 = 0; rd2_expected = 0;
        #STB
        assert_;

        // case2
        @(posedge clk) write_enable3 = 1; write_reg_addr3 = 0; write_data3 = 32'hffffffff; #STB;
        @(posedge clk) write_enable3 = 1; write_reg_addr3 = 14;  write_data3 = 32'hffffffff; #STB;
        @(posedge clk) write_enable3 = 0; write_reg_addr3 = 0; write_data3 = 32'h0;
        read_reg_addr1 = 0; rd1_expected = 32'hffffffff;
        read_reg_addr2 = 14; rd2_expected = 32'hffffffff;
        #STB;
        assert_;

        // case3
        @(posedge clk) read_reg_addr1 = 15; read_reg_addr2 = 15; r15 = 32'hffffffff;
        rd1_expected = 32'hffffffff; rd2_expected = 32'hffffffff;
        #STB;
        assert_;
        @(posedge clk) read_reg_addr1 = 15; read_reg_addr2 = 15; r15 = 32'h0;
        rd1_expected = 32'h0; rd2_expected = 32'h0;
        #STB;
        assert_;
        @(posedge clk) read_reg_addr2 = 15; read_reg_addr2 = 15; r15 = 32'hffffffff;
        rd1_expected = 32'hffffffff; rd2_expected = 32'hffffffff;
        #STB
        assert_;

        // case4 As, RDsのテスト
        @(posedge clk) read_reg_addrs = 14;
        rds_expected = 32'hffffffff;
        #STB
        assert_;



        $display("test completed");
        $finish;
    end
endmodule
