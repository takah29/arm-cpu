module ConditionFlagsGenerator
    (
    input logic [31:0] result1, result2,
    input logic [1:0] cv_flags,
    input logic shifter_carry_out,
    input logic [7:0] instr_11_4,
    input logic not_alu, mult,
    output logic [3:0] cond_flags
    );

    logic n, z, c, v, rrx_en;

    assign n = mult ? result2[31] : result1[31];
    assign z = mult ? ~|{result2, result1} : ~|result1;

    always_comb begin
        if (mult) begin // Mult
            {c, v} = {1'b0, 1'b0};
        end else if ({instr_11_4, not_alu} == 9'b00000_11_0_1) begin // Shifter
            {c, v} = {shifter_carry_out, 1'b0};
        end else begin // Alu
            {c, v} = cv_flags;
        end
    end

    assign cond_flags = {n, z, c, v};
endmodule
