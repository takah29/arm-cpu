module AluWithFlag #(parameter N = 8)
    (
    input logic [N -1:0] a, b,
    input logic [1:0] alu_ctl,
    output logic [N - 1:0] result,
    output logic n, z, c, v
    );

    logic [N - 1:0] condinvb;
    logic [N:0] sum;
    logic cout;

    assign condinvb = alu_ctl[0] ? ~b : b;
    assign sum = a + condinvb + alu_ctl[0];

    always_comb begin
        casex (alu_ctl)
            2'b0?: {cout, result} = sum;
            2'b10: result = a & b;
            2'b11: result = a | b;
        endcase
    end

    assign n = result[N -1];
    assign z = ~|result;
    assign c = cout & ~alu_ctl[1];
    assign v = ~alu_ctl[1] & (a[N - 1] ^ result[N - 1]) & ((~alu_ctl[0] & (a[N - 1] ~^ b[N - 1])) | (alu_ctl[0] & (a[N - 1] ^ b[N -1])));

endmodule
