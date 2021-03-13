module ShifterTestbench;
    parameter DELAY = 10;

    logic [1:0] sh;
    logic [4:0] shamt5;
    logic [31:0] x;
    logic [31:0] y, y_expected;

    Shifter dut(.sh, .shamt5, .x, .y);

    task assert_;
        assert (y === y_expected) else $error("y = %b, %b expected", y, y_expected);
    endtask

    initial begin
        // case1: LSL
        sh = 2'b00;

        shamt5 = '0; x = '1; y_expected = '1; #DELAY;
        assert_;
        shamt5 = 5'b1; x = '1; y_expected = 32'hfffffffe; #DELAY;
        assert_;
        shamt5 = 5'b11111; x = '1; y_expected = 32'h80000000; #DELAY;
        assert_;

        // case2: LSR
        sh = 2'b01;

        shamt5 = '0; x = '1; y_expected = '1; #DELAY;
        assert_;
        shamt5 = 5'b1; x = '1; y_expected = 32'h7fffffff; #DELAY;
        assert_;
        shamt5 = 5'b11111; x = '1; y_expected = 32'h00000001; #DELAY;
        assert_;

        // case3: ASR
        sh = 2'b10;

        shamt5 = '0; x = '1; y_expected = '1; #DELAY;
        assert_;
        shamt5 = 5'b1; x = '1; y_expected = 32'hffffffff; #DELAY;
        assert_;
        shamt5 = 5'b11111; x = '1; y_expected = 32'hffffffff; #DELAY;
        assert_;

        // case4: ROR
        sh = 2'b11;

        shamt5 = '0; x = '1; y_expected = '1; #DELAY;
        assert_;
        shamt5 = 5'b1; x = 32'b1; y_expected = 32'h80000000; #DELAY;
        assert_;
        shamt5 = 5'b11111; x = 32'h7fffffff; y_expected = 32'hfffffffe; #DELAY;
        assert_;

        $display("test completed");
        $finish;
    end
endmodule
