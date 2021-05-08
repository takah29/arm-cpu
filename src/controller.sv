module Controller
    (
    input logic clk, reset,
    input logic [1:0] op,
    input logic [3:0] cond, alu_flags, rd, instr74,
    input logic [5:0] funct,
    output logic pc_src, reg_write3, reg_write1, mem_write, mem_to_reg, alu_src, carry, swap, inv, not_shift,
    output logic [1:0] imm_src, reg_src, result_src,
    output logic [2:0] alu_ctl,
    output logic [3:0] mul_ctl
    );

    logic pcs, reg_w3, reg_w1, mem_w, no_write, mult;
    logic [1:0] flag_w;

    Decoder decoder(
    .op,
    .funct,
    .instr74,
    .rd,
    .pcs,
    .reg_w3,
    .reg_w1,
    .mem_w,
    .mem_to_reg,
    .alu_src,
    .mult,
    .no_write,
    .not_shift,
    .swap,
    .inv,
    .flag_w,
    .imm_src,
    .result_src,
    .reg_src,
    .alu_ctl
    );

    CondLogic cond_logic(
    .clk,
    .reset,
    .pcs,
    .reg_w3,
    .reg_w1,
    .mem_w,
    .no_write,
    .flag_w,
    .cond,
    .alu_flags,
    .pc_src,
    .reg_write3,
    .reg_write1,
    .mem_write,
    .carry
    );

    assign mul_ctl = {mult, funct[3:1]};

endmodule
