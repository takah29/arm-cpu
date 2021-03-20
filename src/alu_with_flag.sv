module AluWithFlag #(parameter N = 32)
    (
    input logic [N -1:0] a, b,
    input logic [2:0] alu_ctl,
    input logic carry,
    output logic [N - 1:0] result,
    output logic n, z, c, v
    );

    logic [N - 1:0] condinvb;
    logic [N:0] sum;
    logic cout, carry_in;
    logic [1:0] alu_ctl_low;

    assign carry_in = alu_ctl[2] ? carry : alu_ctl[0];
    assign condinvb = alu_ctl[0] ? ~b : b;
    assign sum = a + condinvb + carry_in;
    assign alu_ctl_low = alu_ctl[1:0];

    always_comb begin
        casex (alu_ctl_low)
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
