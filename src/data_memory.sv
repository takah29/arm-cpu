module DataMemory(
    input logic clk, write_enable,
    input logic [31:0] address, write_data,
    output logic [31:0] read_data
    );

    logic [31:0] ram[0:1048575]; // 4MB

    assign read_data = ram[address[31:2]];

    always_ff @(posedge clk) begin
        if (write_enable) ram[address[31:2]] <= write_data;
    end

    // 32ビット = 4バイト区切りで指定するので下位2ビットは無視する

endmodule
