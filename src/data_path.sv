module DataPath(
    input logic clk, reset,
    input logic pc_src, reg_write3, reg_write1, mem_to_reg, alu_src, carry, swap, inv, not_shift,
    input logic [31:0] instr, read_data,
    input logic [1:0] imm_src, reg_src, result_src,
    input logic [2:0] alu_ctl,
    input logic [3:0] mul_ctl,
    output logic [3:0] cond_flags,
    output logic [31:0] pc, write_data, data_memory_addr
    );

    logic [31:0] rd2_data, rs_data, pc_plus4, pc_plus8, result, ext_imm, read_data1, read_data3;
    logic [31:0] wd1_mux_out, pc_addr, wd3_pc4_mux_out, alu_block_out1;
    logic [3:0] reg_addr1, reg_addr3;

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
    .read_data3(read_data3),
    .read_datas(rs_data)
    );

    // 直値拡張
    Extend extend(.instr_imm(instr[23:0]), .imm_src, .ext_imm(ext_imm));

    // ALUブロック
    AluBlock alu_block(
    .in1(read_data1),
    .in2(rd2_data),
    .in3(read_data3),
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
    .cond_flags,
    .out1(alu_block_out1),
    .out2(wd1_mux_out)
    );

    assign write_data = read_data3;
    assign data_memory_addr = alu_block_out1;

    Mux2 #(32) result_mux(.d0(alu_block_out1), .d1(read_data), .s(mem_to_reg), .y(result));

endmodule
