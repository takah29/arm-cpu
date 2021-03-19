module Decoder
    (
    input logic [1:0] op,
    input logic [5:0] funct,
    input logic [3:0] rd,
    output logic pcs, reg_w, mem_w, mem_to_reg, alu_src, no_write, shift,
    output logic [1:0] flag_w, imm_src, reg_src, alu_ctl
    );

    logic branch, alu_op;

    MainDecoder main_decoder(
    .op,
    .funct_5(funct[5]),
    .funct_0(funct[0]),
    .branch,
    .mem_to_reg,
    .mem_w,
    .alu_src,
    .reg_w,
    .alu_op,
    .imm_src,
    .reg_src
    );

    AluDecoder alu_decoder(
    .alu_op,
    .s(funct[0]),
    .cmd(funct[4:1]),
    .alu_ctl,
    .flag_w,
    .no_write,
    .shift
    );

    assign pcs = ((rd == 15) & reg_w) | branch;
endmodule
