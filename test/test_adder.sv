module AdderTestbench;
    parameter DELAY = 10;

    logic [31:0] a, b;
    logic cin;
    logic [31:0] s, s_expected;
    logic cout, cout_expected;

    Adder #(32) dut(.a, .b, .cin, .s, .cout);

    task assert_;
        assert (s === s_expected) else $error("s = %d, %d expected", s, s_expected);
        assert (cout === cout_expected) else $error("cout = %d, %d expected", cout, cout_expected);
    endtask

    initial begin
        a = 32'd1000; b = 32'd1000; cin = 1'b0; s_expected = 32'd2000; cout_expected = 1'b0; #DELAY
        assert_;
        a = 32'd4294967295; b = 32'd4294967295; cin = 1'b0; s_expected = 32'd4294967294; cout_expected = 1'b1; #DELAY
        assert_;
        a = 32'd4294967295; b = 32'd0; cin = 1'b1; s_expected = 32'd0; cout_expected = 1'b1; #DELAY
        assert_;

        $display("test completed");
        $finish;
    end
endmodule
