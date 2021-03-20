module Top(
    input logic clk, reset,
    output logic [31:0] write_data, data_memory_addr,
    output logic mem_write
    );

    logic [31:0] pc, instr, read_data;

    ArmCpu arm_cpu(
    .clk,
    .reset,
    .instr,
    .read_data,
    .mem_write,
    .pc,
    .write_data,
    .data_memory_addr
    );

    InstructionMemory imem(pc, instr);
    DataMemory dmem(clk, mem_write, data_memory_addr, write_data, read_data);

endmodule
