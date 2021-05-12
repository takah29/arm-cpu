module AluFlagsGenerator #(parameter N = 32)
    (
    input logic [N -1:0] result,
    input logic [1:0] cv_flags,
    input logic shifter_carry_out,
    input logic [7:0] instr_11_4,
    input logic not_alu,
    output logic [3:0] alu_flags
    );

    logic n, z, c, v, rrx_en;

    assign n = result[N - 1];
    assign z = ~|result;
    assign rrx_en = {instr_11_4, not_alu} == 9'b00000_11_0_1; // RRX
    assign c = rrx_en ? shifter_carry_out : cv_flags[1];
    assign v = cv_flags[0];

    assign alu_flags = {n, z, c, v};
endmodule
