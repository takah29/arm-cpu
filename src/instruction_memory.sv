module InstructionMemory(
    input logic [31:0] address,
    output logic [31:0] read_data
    );

    logic [31:0] ram[0:4095];

    // 32ビット = 4バイト区切りで指定するので下位2ビットは無視する
    assign read_data = ram[address[31:2]];
endmodule
