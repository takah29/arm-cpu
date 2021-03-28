module Multiplier
    (
    input logic [31:0] a, b, c, d, // Rn, Rm, Rd, Ra
    input logic [2:0] cmd,
    output logic [31:0] ret1, ret2 // Rd, Ra
    );

    function [63:0] signed_mult(input [31:0] a_in, b_in);
        signed_mult = $signed(a_in) * $signed(b_in);
    endfunction

    always_comb begin
        case(cmd)
            3'b000: ret1 = a * b; // MUL
            3'b001: ret1 = a * b + d; // MLA
            3'b100: {ret1, ret2} = a * b; // UMULL
            3'b101: {ret1, ret2} = a * b + {c, d}; // UMLAL
            3'b110: {ret1, ret2} = signed_mult(a, b); // SMULL
            3'b111: {ret1, ret2} = signed_mult(a, b) + {c, d}; // SMLAL
            default: {ret1, ret2} = 63'bx;
        endcase
    end
endmodule
