module ArmCpu
    (
    input logic clk, reset,
    input logic [31:0] instr, read_data,
    output logic mem_write,
    output logic [31:0] pc, write_data, data_memory_addr
    );

    logic pc_src, reg_write, mem_to_reg, alu_src, shift, carry;
    logic [1:0] imm_src, reg_src;
    logic [2:0] alu_ctl;
    logic [3:0] alu_flags;

    DataPath data_path(
    .clk,
    .reset,
    .pc_src,
    .reg_write,
    .mem_to_reg,
    .alu_src,
    .shift,
    .carry,
    .instr,
    .read_data,
    .imm_src,
    .alu_ctl,
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
    .pc_src,
    .reg_write,
    .mem_write,
    .mem_to_reg,
    .alu_src,
    .shift,
    .carry,
    .imm_src,
    .reg_src,
    .alu_ctl
    );

endmodule
