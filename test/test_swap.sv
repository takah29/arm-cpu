module SwapTestbench;
    parameter DELAY = 10;

    logic [31:0] x0, x1;
    logic en;
    logic [31:0] y0, y1, y0_exp, y1_exp;

    Swap #(32) dut(.x0, .x1, .en, .y0, .y1);

    task assert_;
        assert (y0 === y0_exp) else $error("y0 = %d, %d expected", y0, y0_exp);
        assert (y1 === y1_exp) else $error("y1 = %d, %d expected", y1, y1_exp);
    endtask

    initial begin
        // OFF
        x0 = 32'b0; x1 = 32'b1; en = 1'b0;
        y0_exp = 32'b0; y1_exp = 32'b1; #DELAY;
        assert_;

        // ON
        x0 = 32'b0; x1 = 32'b1; en = 1'b1;
        y0_exp = 32'b1; y1_exp = 32'b0; #DELAY;
        assert_;

        $display("test completed");
        $finish;
    end
endmodule
