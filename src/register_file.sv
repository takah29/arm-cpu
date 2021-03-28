module RegisterFile(
    input logic clk, reset,
    input logic write_enable1, write_enable3,
    input logic [3:0] read_reg_addr1, read_reg_addr2, write_reg_addr3, read_reg_addrs,
    input logic [31:0] write_data1, write_data3, r15,
    output logic [31:0] read_data1, read_data2, read_data3, read_datas
    );

    logic [31:0] reg_file[0:14];

    assign read_data1 = (read_reg_addr1 == 4'b1111) ? r15 : reg_file[read_reg_addr1];
    assign read_data2 = (read_reg_addr2 == 4'b1111) ? r15 : reg_file[read_reg_addr2];
    assign read_data3 = (write_reg_addr3 == 4'b1111) ? r15 : reg_file[write_reg_addr3];
    assign read_datas = (read_reg_addrs == 4'b1111) ? r15 : reg_file[read_reg_addrs];

    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            foreach(reg_file[i]) begin
                reg_file[i] <= '0;
            end
        end
        if (write_enable1) begin
            reg_file[read_reg_addr1] <= write_data1;
        end
        if (write_enable3) begin
            reg_file[write_reg_addr3] <= write_data3;
        end
    end
endmodule
