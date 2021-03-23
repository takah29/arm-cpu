module ShifterTestbench;
    parameter DELAY = 10;

    logic [1:0] shift_type;
    logic [7:0] shift_num;
    logic [31:0] x;
    logic [31:0] y, y_expected;

    Shifter dut(.shift_type, .shift_num, .x, .y);

    task assert_;
        assert (y === y_expected) else $error("y = %b, %b expected", y, y_expected);
    endtask

    initial begin
        // case1: LSL
        shift_type = 2'b00;

        shift_num = '0; x = '1; y_expected = '1; #DELAY;
        assert_;
        shift_num = 8'b00000001; x = '1; y_expected = 32'hfffffffe; #DELAY;
        assert_;
        shift_num = 8'b00011111; x = '1; y_expected = 32'h80000000; #DELAY;
        assert_;

        // case2: LSR
        shift_type = 2'b01;

        shift_num = '0; x = '1; y_expected = '1; #DELAY;
        assert_;
        shift_num = 8'b00000001; x = '1; y_expected = 32'h7fffffff; #DELAY;
        assert_;
        shift_num = 8'b00011111; x = '1; y_expected = 32'h00000001; #DELAY;
        assert_;

        // case3: ASR
        shift_type = 2'b10;

        shift_num = '0; x = '1; y_expected = '1; #DELAY;
        assert_;
        shift_num = 8'b00000001; x = '1; y_expected = 32'hffffffff; #DELAY;
        assert_;
        shift_num = 8'b00011111; x = '1; y_expected = 32'hffffffff; #DELAY;
        assert_;

        // case4: ROR
        shift_type = 2'b11;

        shift_num = '0; x = '1; y_expected = '1; #DELAY;
        assert_;
        shift_num = 8'b00000001; x = 32'b1; y_expected = 32'h80000000; #DELAY;
        assert_;
        shift_num = 8'b00011111; x = 32'h7fffffff; y_expected = 32'hfffffffe; #DELAY;
        assert_;

        $display("test completed");
        $finish;
    end
endmodule
