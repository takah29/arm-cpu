module DataPath(
    input logic clk, reset,
    input logic pc_src, imm_src, reg_write,
    input logic [31:0] instr, read_data,
    input logic [1:0] alu_ctl,
    output logic [3:0] alu_flags,
    output logic [31:0] pc, write_data, alu_result
    );

    logic [31:0] src_a, src_b, pc_plus8;

    PcModule pc_module(.clk(clk), .pc_src(pc_src), .jump(read_data), .pc(pc), .pc_plus8(pc_plus8));

    RegisterFile register_file(
    .clk(clk),
    .write_enable3(reg_write),
    .read_reg_addr1(instr[19:16]),
    .read_reg_addr2(instr[15:12]),
    .write_reg_addr3(instr[15:12]),
    .write_data3(read_data),
    .r15(pc_plus8),
    .read_data1(src_a),
    .read_data2(write_data)
    );

    Extend extend(.instr_imm(instr[11:0]), .imm_src(imm_src), .ext_imm(src_b));

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

endmodule
