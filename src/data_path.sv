module DataPath(
    input logic clk, reset,
    input logic pc_src, reg_write3, reg_write1, mem_to_reg, alu_src, carry, swap, inv, not_shift,
    input logic [31:0] instr, read_data,
    input logic [1:0] imm_src, reg_src, result_src,
    input logic [2:0] alu_ctl,
    input logic [3:0] mul_ctl,
    output logic [3:0] alu_flags,
    output logic [31:0] pc, write_data, data_memory_addr
    );

    logic [31:0] rd2_data, rs_data, pc_plus4, pc_plus8, result, ext_imm, read_data1;
    logic [31:0] wd3_mux_out, wd1_mux_out, pc_addr, wd3_pc4_mux_out;
    logic [3:0] reg_addr1, reg_addr3;
    logic [31:0] tmp_write_data, tmp_data_memory_addr;

    // プログラムカウンタ
    assign pc_addr = result & 32'hfffffffe;
    PcModule pc_module(.clk, .reset, .pc_src, .jump(pc_addr), .pc, .pc_plus4);
    assign pc_plus8 = pc_plus4 + 4;

    // レジスタファイル
    Mux2 #(4) reg_addr0_mux(.d0(instr[19:16]), .d1(4'hf), .s(reg_src[0]), .y(reg_addr1)); // Rn or PC
    Mux2 #(4) reg_addr1_mux(.d0(instr[15:12]), .d1(4'he), .s(reg_src[1]), .y(reg_addr3)); // Rm or LR
    Mux2 #(32) wd3_pc4_mux(.d0(result), .d1(pc_plus4), .s(reg_src[1]), .y(wd3_pc4_mux_out)); // WriteData3 or PC + 4
    RegisterFile register_file(
    .clk,
    .reset,
    .write_enable1(reg_write1),
    .write_enable3(reg_write3),
    .read_reg_addr1(reg_addr1),
    .read_reg_addr2(instr[3:0]),
    .read_reg_addrs(instr[11:8]),
    .write_reg_addr3(reg_addr3),
    .write_data1(wd1_mux_out),
    .write_data3(wd3_pc4_mux_out),
    .r15(pc_plus8),
    .read_data1(read_data1),
    .read_data2(rd2_data),
    .read_data3(tmp_write_data),
    .read_datas(rs_data)
    );

    // 直値拡張
    Extend extend(.instr_imm(instr[23:0]), .imm_src, .ext_imm(ext_imm));

    // ALUブロック
    AluBlock alu_block(
    .in1(read_data1),
    .in2(rd2_data),
    .in3(tmp_write_data),
    .in4(rs_data),
    .instr_11_4(instr[11:4]),
    .ext_imm(ext_imm),
    .alu_src,
    .carry,
    .swap,
    .inv,
    .not_shift,
    .result_src,
    .alu_ctl,
    .mul_ctl,
    .alu_flags,
    .write_data,
    .data_memory_addr,
    .write_data1(wd1_mux_out)
    );

    Mux2 #(32) result_mux(.d0(data_memory_addr), .d1(read_data), .s(mem_to_reg), .y(result));
endmodule

module AluBlock(
    input logic [31:0] in1, in2, in3, in4,
    input logic [7:0] instr_11_4,
    input logic [31:0] ext_imm,
    input logic alu_src, carry, swap, inv, not_shift,
    input logic [1:0] result_src,
    input logic [2:0] alu_ctl,
    input logic [3:0] mul_ctl,
    output logic [3:0] alu_flags,
    output logic [31:0] write_data, data_memory_addr,
    output logic [31:0] write_data1
    );

    logic [31:0] src_a, src_b, pre_src_b, rd2_data, rs_data, result, shifted, alu_result, read_data1, shift_imm_out;
    logic [31:0] mult_out1, mult_out2, wd1_mux_out, alu_result_mux_out;
    logic [3:0] pre_alu_flags;
    logic sifter_c, rrx_en;

    // シフタ
    logic [7:0] shift_num;
    // rs_dataは下位8ビットだけ使う
    Mux2 #(8) shift_imm_reg_mux(.d0({3'b000, instr_11_4[7:3]}), .d1(in4[7:0]), .s(instr_11_4[0]), .y(shift_num));
    Shifter shifter(
    .shift_type(instr_11_4[2:1]),
    .shift_num(shift_num),
    .not_shift,
    .instr4(instr_11_4[0]),
    .x(in2),
    .carry,
    .y(shifted),
    .c(sifter_c)
    );

    assign write_data = in3;

    // ALU
    Mux2 #(32) alu_src_b_mux(.d0(shifted), .d1(ext_imm), .s(alu_src), .y(shift_imm_out));
    Swap src_swap(.x0(in1), .x1(shift_imm_out), .en(swap), .y0(src_a), .y1(pre_src_b));
    assign src_b = inv ? ~pre_src_b : pre_src_b;
    AluWithFlag #(32) alu(
    .a(src_a),
    .b(src_b),
    .alu_ctl,
    .carry,
    .result(alu_result),
    .n(pre_alu_flags[3]),
    .z(pre_alu_flags[2]),
    .c(pre_alu_flags[1]),
    .v(pre_alu_flags[0])
    );

    Mux4 #(32) alu_result_src_b_mux(
    .d0(alu_result),
    .d1(src_b),
    .d2(in1),
    .d3(in1),
    .s(result_src),
    .y(alu_result_mux_out)
    );

    Mux2 #(32) alu_mult_mux(
    .d0(alu_result_mux_out),
    .d1(mult_out2),
    .s(mul_ctl[3]),
    .y(data_memory_addr)
    );

    // RRX Carry Replacement
    assign rrx_en = {instr_11_4, result_src[0]} == 9'b00000_11_0_1; // result_src[0] = not_alu
    assign alu_flags = {pre_alu_flags[3:2], rrx_en ? sifter_c : pre_alu_flags[1], pre_alu_flags[0]};

    // Multiplier
    Multiplier mult(
    .a(in2),
    .b(in4),
    .c(in1),
    .d(in3),
    .cmd(mul_ctl[2:0]),
    .ret1(mult_out1),
    .ret2(mult_out2)
    );

    Mux2 #(32) wd1_mux(.d0(alu_result), .d1(mult_out1), .s(mul_ctl[3]), .y(write_data1));
endmodule