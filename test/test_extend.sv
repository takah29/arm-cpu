module ExtendTestbench;
    parameter DELAY = 10;

    logic [23:0] instr_imm;
    logic [1:0] imm_src;
    logic [31:0] ext_imm, ext_imm_expected;

    Extend dut(.instr_imm, .imm_src, .ext_imm);

    task assert_;
        assert (ext_imm === ext_imm_expected) else $error("ext_imm = %b, %b expected", ext_imm, ext_imm_expected);
    endtask

    initial begin
        // case1
        instr_imm = 0; imm_src = 2'b01; ext_imm_expected = 0; #DELAY;
        assert_;

        // case2: extend 8bit imm
        instr_imm = 24'h0000ff; imm_src = 2'b00; ext_imm_expected = 32'h000000ff; #DELAY;
        assert_;

        // case3: extend 12bit imm
        instr_imm = 24'h000fff; imm_src = 2'b01; ext_imm_expected = 32'h00000fff; #DELAY;
        assert_;

        // case4: extend 24bit imm
        instr_imm = 24'b111111111111111111111111; imm_src = 2'b10;
        ext_imm_expected = 32'b11111111111111111111111111111100; #DELAY;
        assert_;

        // case5: not defined
        instr_imm = 24'b111111111111111111111111; imm_src = 2'b11;
        ext_imm_expected = 32'bx; #DELAY;
        assert_;


        $display("test completed");
        $finish;
    end
endmodule
