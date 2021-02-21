module Extend
    (
    input logic [11:0] instr_imm,
    output logic [31:0] ext_imm
    );

    assign ext_imm = {24'b0, instr_imm};
endmodule
