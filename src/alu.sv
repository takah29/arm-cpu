module Alu #(parameter N = 32)
    (
    input logic [N -1:0] a, b,
    input logic [2:0] alu_ctl,
    input logic carry,
    output logic [N - 1:0] result,
    output logic [1:0] cv_flags
    );

    logic [N - 1:0] condinvb;
    logic [N:0] sum;
    logic carry_in, cout;
    logic c, v;

    assign carry_in = alu_ctl[2] ? carry : alu_ctl[0];
    assign condinvb = alu_ctl[0] ? ~b : b;
    assign sum = a + condinvb + carry_in;

    always_comb begin
        casex (alu_ctl)
            3'b?0?: {cout, result} = sum;
            3'b010: result = a & b;
            3'b011: result = a | b;
            3'b110: result = a ^ b;
            default: {cout, result} = 'x;
        endcase
    end

    assign c = cout & ~alu_ctl[1];
    assign v = ~alu_ctl[1] & (a[N - 1] ^ result[N - 1]) & ((~alu_ctl[0] & (a[N - 1] ~^ b[N - 1])) | (alu_ctl[0] & (a[N - 1] ^ b[N -1])));
    assign cv_flags = {c, v};
endmodule
