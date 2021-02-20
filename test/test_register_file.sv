module RegisterFileTestbench();
    parameter HALF_CYCLE = 500;
    parameter STB = 100;

    logic clk, write_enable3;
    logic [3:0] read_addr1, read_addr2, write_addr3;
    logic [31:0] write_data3, r15;
    logic [31:0] read_data1, read_data2, rd1_expected, rd2_expected;

    RegisterFile dut(.clk, .write_enable3, .read_addr1, .read_addr2,
    .write_addr3, .write_data3, .r15, .read_data1, .read_data2);

    task assert_;
        assert (read_data1 === rd1_expected) else $error("read_data1 = %h, %h expected", read_data1, rd1_expected);
        assert (read_data2 === rd2_expected) else $error("read_data2 = %h, %h expected", read_data2, rd2_expected);
    endtask

    always begin
        clk = 0;
        #HALF_CYCLE;
        clk = 1;
        #HALF_CYCLE;
    end

    initial begin
        // initialize
        for (int i = 0; i < 15; i++) begin
            @(posedge clk) write_addr3 = i; write_enable3 = 1; write_data3 = 0; #STB;
        end

        // case1
        @(posedge clk) write_enable3 = 0; write_data3 = 0;
        read_addr1 = 0; rd1_expected = 0;
        read_addr2 = 0; rd2_expected = 0;
        #STB
        assert_;

        // case2
        @(posedge clk) write_enable3 = 1; write_addr3 = 0; write_data3 = 32'hffffffff; #STB;
        @(posedge clk) write_enable3 = 1; write_addr3 = 14;  write_data3 = 32'hffffffff; #STB;
        @(posedge clk) write_enable3 = 0; write_addr3 = 0; write_data3 = 32'h0;
        read_addr1 = 0; rd1_expected = 32'hffffffff;
        read_addr2 = 14; rd2_expected = 32'hffffffff;
        #STB;
        assert_;

        // case3
        @(posedge clk) read_addr1 = 15; read_addr2 = 15; r15 = 32'hffffffff;
        rd1_expected = 32'hffffffff; rd2_expected = 32'hffffffff;
        #STB;
        assert_;
        @(posedge clk) read_addr1 = 15; read_addr2 = 15; r15 = 32'h0;
        rd1_expected = 32'h0; rd2_expected = 32'h0;
        #STB;
        assert_;
        @(posedge clk) read_addr2 = 15; read_addr2 = 15; r15 = 32'hffffffff;
        rd1_expected = 32'hffffffff; rd2_expected = 32'hffffffff;
        #STB
        assert_;

        $display("test completed");
        $finish;
    end
endmodule
