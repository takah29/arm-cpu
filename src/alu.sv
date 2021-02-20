module Alu #(parameter N = 8)
    (
    input logic [N -1:0] a, b,
    input logic [1:0] alu_ctl,
    output logic [N - 1:0] result
    );

    logic [N - 1:0] condinvb;
    logic [N:0] sum;

    assign condinvb = alu_ctl[0] ? ~b : b;
    assign sum = a + condinvb + alu_ctl[0];

    always_comb begin
        casex (alu_ctl)
            2'b0x: result = sum;
            2'b10: result = a & b;
            2'b11: result = a | b;
        endcase
    end
endmodule
