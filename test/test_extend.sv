module ExtendTestbench;
    parameter DELAY = 10;

    logic [11:0] instr_imm;
    logic imm_src;
    logic [31:0] ext_imm, ext_imm_expected;

    Extend dut(.instr_imm, .imm_src, .ext_imm);

    task assert_;
        assert (ext_imm === ext_imm_expected) else $error("ext_imm = %b, %b expected", ext_imm, ext_imm_expected);
    endtask

    initial begin
        // case1
        instr_imm = 0; imm_src = 1'b1; ext_imm_expected = 0; #DELAY;
        assert_;

        // case2: extend 12bit imm
        instr_imm = 12'hfff; imm_src = 1'b1; ext_imm_expected = 32'h00000fff; #DELAY;
        assert_;

        // case2: extend 8bit imm
        instr_imm = 8'hff; imm_src = 1'b0; ext_imm_expected = 32'h000000ff; #DELAY;
        assert_;

        $display("test completed");
        $finish;
    end
endmodule
