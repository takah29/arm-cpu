module DataMemoryTestbench();
    parameter HALF_CYCLE = 500;
    parameter STB = 100;

    logic clk, write_enable;
    logic [31:0] address, write_data;
    logic [31:0] read_data, rd_expected;

    DataMemory dut(.clk, .address, .read_data, .write_enable, .write_data);

    task assert_;
        assert (read_data === rd_expected) else $error("read_data = %h, %h expected", read_data,rd_expected);
    endtask

    always begin
        clk = 0;
        #HALF_CYCLE;
        clk = 1;
        #HALF_CYCLE;
    end

    initial begin
        // initialize
        for (int i = 0; i < 64; i++) begin
            @(posedge clk) address = 4 * i; write_enable = 1; write_data = 0; #STB;
        end

        // case1
        @(posedge clk) address = 0; write_enable = 0; write_data = 0; rd_expected = 0; #STB;
        assert_;

        // case2
        @(posedge clk) address = 0; write_enable = 1; write_data = 32'hffffffff; #STB;
        @(posedge clk) address = 0; write_enable = 0; write_data = 32'h0; rd_expected = 32'hffffffff; #STB;
        assert_;

        // case3
        @(posedge clk) address = 64 * 4; write_enable = 1; write_data = 32'hffffffff; #STB;
        @(posedge clk) address = 64 * 4; write_enable = 0; write_data = 32'h0; rd_expected = 32'hffffffff; #STB;
        assert_;

        $display("test completed");
        $finish;
    end
endmodule
