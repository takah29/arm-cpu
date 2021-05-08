module ArmCpu
    (
    input logic clk, reset,
    input logic [31:0] instr, read_data,
    output logic mem_write,
    output logic [31:0] pc, write_data, data_memory_addr
    );

    logic pc_src, reg_write3, reg_write1, mem_to_reg, alu_src, carry, swap, inv, not_shift;
    logic [1:0] imm_src, reg_src, result_src;
    logic [2:0] alu_ctl;
    logic [3:0] alu_flags, mul_ctl;

    DataPath data_path(
    .clk,
    .reset,
    .pc_src,
    .reg_write3,
    .reg_write1,
    .mem_to_reg,
    .alu_src,
    .carry,
    .swap,
    .inv,
    .not_shift,
    .instr,
    .read_data,
    .imm_src,
    .result_src,
    .alu_ctl,
    .mul_ctl,
    .reg_src,
    .alu_flags,
    .pc,
    .write_data,
    .data_memory_addr
    );

    Controller controller(
    .clk,
    .reset,
    .op(instr[27:26]),
    .cond(instr[31:28]),
    .alu_flags,
    .rd(instr[15:12]),
    .funct(instr[25:20]),
    .instr74(instr[7:4]),
    .pc_src,
    .reg_write3,
    .reg_write1,
    .mem_write,
    .mem_to_reg,
    .alu_src,
    .carry,
    .swap,
    .inv,
    .not_shift,
    .imm_src,
    .result_src,
    .reg_src,
    .alu_ctl,
    .mul_ctl
    );

endmodule
