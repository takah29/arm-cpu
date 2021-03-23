module Controller
    (
    input logic clk, reset,
    input logic [1:0] op,
    input logic [3:0] cond, alu_flags, rd,
    input logic [5:0] funct,
    output logic pc_src, reg_write, mem_write, mem_to_reg, alu_src, shift, carry, swap,
    output logic [1:0] imm_src, reg_src,
    output logic [2:0] alu_ctl
    );

    logic pcs, reg_w, mem_w, no_write;
    logic [1:0] flag_w;

    Decoder decoder(
    .op,
    .funct,
    .rd,
    .pcs,
    .reg_w,
    .mem_w,
    .mem_to_reg,
    .alu_src,
    .no_write,
    .shift,
    .swap,
    .flag_w,
    .imm_src,
    .reg_src,
    .alu_ctl
    );

    CondLogic cond_logic(
    .clk,
    .reset,
    .pcs,
    .reg_w,
    .mem_w,
    .no_write,
    .flag_w,
    .cond,
    .alu_flags,
    .pc_src,
    .reg_write,
    .mem_write,
    .carry
    );

endmodule
