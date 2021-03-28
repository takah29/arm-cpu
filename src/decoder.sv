module Decoder
    (
    input logic [1:0] op,
    input logic [5:0] funct,
    input logic [3:0] rd,
    output logic pcs, reg_w, mem_w, mem_to_reg, alu_src, reg_src, base_reg_write, no_write, swap, inv,
    output logic [1:0] flag_w, imm_src, result_src,
    output logic [2:0] alu_ctl
    );

    logic branch, alu_op, shift, post_idx;

    MainDecoder main_decoder(
    .op,
    .funct,
    .branch,
    .mem_to_reg,
    .mem_w,
    .alu_src,
    .imm_src,
    .reg_w,
    .reg_src,
    .alu_op,
    .post_idx,
    .base_reg_write
    );

    AluDecoder alu_decoder(
    .alu_op,
    .s(funct[0]),
    .cmd(funct[4:1]),
    .alu_ctl,
    .flag_w,
    .no_write,
    .shift,
    .swap,
    .inv
    );

    assign pcs = ((rd == 15) & reg_w) | branch;
    assign result_src = {post_idx, shift};
endmodule
