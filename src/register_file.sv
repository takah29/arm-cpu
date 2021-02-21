module RegisterFile(
    input logic clk, write_enable3,
    input logic [3:0] read_reg_addr1, read_reg_addr2, write_reg_addr3,
    input logic [31:0] write_data3, r15,
    output logic [31:0] read_data1, read_data2
    );

    logic [31:0] register_file[0:14];

    assign read_data1 = (read_reg_addr1 == 4'b1111) ? r15 : register_file[read_reg_addr1];
    assign read_data2 = (read_reg_addr2 == 4'b1111) ? r15 : register_file[read_reg_addr2];

    always_ff @(posedge clk) begin
        if (write_enable3) register_file[write_reg_addr3] <= write_data3;
    end
endmodule
