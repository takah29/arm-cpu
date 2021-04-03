module PcModule(
    input logic clk, reset,
    input logic pc_src,
    input logic [31:0] jump,
    output logic [31:0] pc, pc_plus4
    );

    logic [31:0] pc_next;

    Mux2 #(32) mux(.d0(pc_plus4), .d1(jump), .s(pc_src), .y(pc_next));
    Flopr #(32) pcreg(.clk(clk), .reset(reset), .d(pc_next), .q(pc));
    Adder #(32) plus4(.a(pc), .b(32'b100), .cin(1'b0), .s(pc_plus4), .cout());
endmodule
