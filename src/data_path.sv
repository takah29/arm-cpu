module DataPath(
    input logic clk, reset,
    input logic pc_src, reg_write3, reg_write1, mem_to_reg, alu_src, reg_src, carry, swap, inv,
    input logic [31:0] instr, read_data,
    input logic [1:0] imm_src, result_src,
    input logic [2:0] alu_ctl,
    input logic [3:0] mul_ctl,
    output logic [3:0] alu_flags,
    output logic [31:0] pc, write_data, data_memory_addr
    );

    logic [31:0] src_a, src_b, pre_src_b, rd2_data, rs_data, pc_plus8, result, ext_imm, shifted, alu_result, read_data1, shift_imm_out;
    logic [31:0] mult_out1, mult_out2, wd3_mux_out, wd1_mux_out;
    logic [3:0] reg_addr1, reg_addr2;

    // プログラムカウンタ
    PcModule pc_module(.clk, .reset, .pc_src, .jump(result), .pc, .pc_plus8);

    // レジスタファイル
    RegisterFile register_file(
    .clk,
    .reset,
    .write_enable1(reg_write1),
    .write_enable3(reg_write3),
    .read_reg_addr1(reg_addr1),
    .read_reg_addr2(instr[3:0]),
    .read_reg_addrs(instr[11:8]),
    .write_reg_addr3(instr[15:12]),
    .write_data1(wd1_mux_out),
    .write_data3(wd3_mux_out),
    .r15(pc_plus8),
    .read_data1(read_data1),
    .read_data2(rd2_data),
    .read_data3(write_data),
    .read_datas(rs_data)
    );
    Mux2 #(4) reg_addr0_mux(.d0(instr[19:16]), .d1(4'hf), .s(reg_src), .y(reg_addr1));

    // 直値拡張
    Extend extend(.instr_imm(instr[23:0]), .imm_src, .ext_imm);

    // シフタ
    logic [7:0] shift_num;
    // rs_dataは下位8ビットだけ使う
    Mux2 #(8) shift_imm_reg_mux(.d0({3'b000, instr[11:7]}), .d1(rs_data[7:0]), .s(instr[4]), .y(shift_num));
    Shifter shifter(.shift_type(instr[6:5]), .shift_num(shift_num), .x(rd2_data), .y(shifted));

    // ALU
    Mux2 #(32) alu_src_b_mux(.d0(shifted), .d1(ext_imm), .s(alu_src), .y(shift_imm_out));
    Swap src_swap(.x0(read_data1), .x1(shift_imm_out), .en(swap), .y0(src_a), .y1(pre_src_b));
    assign src_b = inv ? ~pre_src_b : pre_src_b;
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

    Mux4 #(32) alu_result_src_b_mux(.d0(alu_result), .d1(src_b), .d2(read_data1), .d3(read_data1), .s(result_src), .y(data_memory_addr));
    Mux2 #(32) result_mux(.d0(data_memory_addr), .d1(read_data), .s(mem_to_reg), .y(result));

    // Multiplier
    Multiplier mult(.a(rd2_data), .b(rs_data), .c(read_data1), .d(write_data), .cmd(mul_ctl[2:0]), .ret1(mult_out1), .ret2(mult_out2));
    Mux2 #(32) wd1_mux(.d0(alu_result), .d1(mult_out1), .s(mul_ctl[3]), .y(wd1_mux_out));
    Mux2 #(32) wd3_mux(.d0(result), .d1(mult_out2), .s(mul_ctl[3]), .y(wd3_mux_out));
endmodule
