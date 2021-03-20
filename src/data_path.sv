module DataPath(
    input logic clk, reset,
    input logic pc_src, reg_write, mem_to_reg, alu_src, shift, carry,
    input logic [31:0] instr, read_data,
    input logic [1:0] imm_src,
    input logic [2:0] reg_src, alu_ctl,
    output logic [3:0] alu_flags,
    output logic [31:0] pc, write_data, data_memory_addr
    );

    logic [31:0] src_a, src_b, pc_plus8, result, ext_imm, shifted, alu_result;
    logic [3:0] reg_addr1, reg_addr2;

    // プログラムカウンタ
    PcModule pc_module(.clk, .reset, .pc_src, .jump(result), .pc, .pc_plus8);

    // レジスタファイル
    logic [3:0] reg_addr0_mux_out;
    RegisterFile register_file(
    .clk,
    .reset,
    .write_enable3(reg_write),
    .read_reg_addr1(reg_addr1),
    .read_reg_addr2(reg_addr2),
    .write_reg_addr3(instr[15:12]),
    .write_data3(result),
    .r15(pc_plus8),
    .read_data1(src_a),
    .read_data2(write_data)
    );
    Mux2 #(4) reg_addr0_mux(.d0(instr[19:16]), .d1(4'hf), .s(reg_src[0]), .y(reg_addr0_mux_out));
    Mux2 #(4) reg_addr1_mux(.d0(instr[3:0]), .d1(instr[15:12]), .s(reg_src[1]), .y(reg_addr2));
    Mux2 #(4) reg_addr2_mux(.d0(reg_addr0_mux_out), .d1(instr[11:8]), .s(reg_src[2] & instr[4]), .y(reg_addr1));


    // 直値拡張
    Extend extend(.instr_imm(instr[23:0]), .imm_src, .ext_imm);

    // シフタ
    logic [4:0] shamt5;
    Mux2 #(5) shift_imm_reg_mux(.d0(instr[11:7]), .d1(src_a[4:0]), .s(instr[4]), .y(shamt5));
    Shifter shifter(.sh(instr[6:5]), .shamt5(shamt5), .x(write_data), .y(shifted));

    // ALU
    AluWithFlag #(32) alu(
    .a(src_a),
    .b(src_b),
    .alu_ctl,
    .carry,
    .result(alu_result),
    .n(alu_flags[3]),
    .z(alu_flags[2]),
    .c(alu_flags[1]),
    .v(alu_flags[0])
    );
    Mux2 #(32) alu_src_b_mux(.d0(shifted), .d1(ext_imm), .s(alu_src), .y(src_b));

    Mux2 #(32) alu_result_src_b_mux(.d0(alu_result), .d1(src_b), .s(shift), .y(data_memory_addr));
    Mux2 #(32) result_mux(.d0(data_memory_addr), .d1(read_data), .s(mem_to_reg), .y(result));

endmodule
