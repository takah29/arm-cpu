module DataPath(
    input logic clk, reset,
    input logic pc_src, imm_src, reg_write, mem_to_reg, alu_src,
    input logic [31:0] instr, read_data,
    input logic [1:0] alu_ctl, reg_src,
    output logic [3:0] alu_flags,
    output logic [31:0] pc, write_data, alu_result
    );

    logic [31:0] src_a, src_b, pc_plus8, result, ext_imm;
    logic [3:0] reg_addr1, reg_addr2;

    // プログラムカウンタ
    PcModule pc_module(.clk(clk), .pc_src(pc_src), .jump(result), .pc(pc), .pc_plus8(pc_plus8));

    // レジスタファイル
    RegisterFile register_file(
    .clk(clk),
    .write_enable3(reg_write),
    .read_reg_addr1(reg_addr1),
    .read_reg_addr2(reg_addr2),
    .write_reg_addr3(instr[15:12]),
    .write_data3(read_data),
    .r15(pc_plus8),
    .read_data1(src_a),
    .read_data2(write_data)
    );
    Mux2 #(4) reg_addr1_mux(.d0(instr[19:16]), .d1(4'hf), .s(reg_src[1]), .y(reg_addr1));
    Mux2 #(4) reg_addr2_mux(.d0(instr[3:0]), .d1(instr[15:12]), .s(reg_src[0]), .y(reg_addr2));

    // 直値拡張
    Extend extend(.instr_imm(instr[11:0]), .imm_src(imm_src), .ext_imm(ext_imm));

    // ALU
    AluWithFlag #(32) alu(
    .a(src_a),
    .b(src_b),
    .alu_ctl(alu_ctl),
    .result(alu_result),
    .n(alu_flags[3]),
    .z(alu_flags[2]),
    .c(alu_flags[1]),
    .v(alu_flags[0])
    );
    Mux2 #(32) alu_src_b_mux(.d0(write_data), .d1(ext_imm), .s(alu_src), .y(src_b));

    Mux2 #(32) result_mux(.d0(alu_result), .d1(read_data), .s(mem_to_reg), .y(result));

endmodule
