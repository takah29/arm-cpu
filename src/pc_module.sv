module PcModule(
    input logic clk, pc_src,
    input logic [31:0] jump,
    output logic [31:0] pc, pc_plus8
    );

    logic [31:0] pc_next, pc_plus4;

    Mux2 #(32) mux(.d0(pc_plus4), .d1(jump), .s(pc_src), .y(pc_next));
    Flopr #(32) pcreg(.clk(clk), .reset(), .d(pc_next), .q(pc));
    Adder #(32) plus4_1(.a(pc), .b(32'b100), .cin(1'b0), .s(pc_plus4), .cout());
    Adder #(32) plus4_2(.a(32'b100), .b(pc_plus4), .cin(1'b0), .s(pc_plus8), .cout());
endmodule
