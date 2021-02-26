module PcModuleTestbench();
    parameter HALF_CYCLE = 500;
    parameter STB = 100;

    logic clk, pc_src;
    logic [31:0] jump, pc, pc_plus8;
    logic [31:0] pc_expected, pc_plus8_expected;

    PcModule dut(.clk, .pc_src, .jump, .pc, .pc_plus8);

    task assert_;
        assert (pc === pc_expected) else $error("pc = %h, %h expected", pc, pc_expected);
        assert (pc_plus8 === pc_plus8_expected) else $error("pc_plus8 = %h, %h expected", pc_plus8, pc_plus8_expected);
    endtask

    always begin
        clk = 0;
        #HALF_CYCLE;
        clk = 1;
        #HALF_CYCLE;
    end

    initial begin
        // PC初期化
        pc_src = 1; jump = 0; pc_expected = 0; pc_plus8_expected = 8;
        @(posedge clk)
        #STB;
        assert_;

        // カウントアップ
        pc_src = 0; jump = 0; pc_expected = 4; pc_plus8_expected = 12;
        @(posedge clk)
        #STB;
        assert_;

        // ジャンプ
        pc_src = 1; jump = 1024; pc_expected = 1024; pc_plus8_expected = 1032;
        @(posedge clk)
        #STB;
        assert_;

        $display("test completed");
        $finish;
    end
endmodule
