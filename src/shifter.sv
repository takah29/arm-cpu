module Shifter
    (
    input logic [1:0] sh,
    input logic [4:0] shamt5,
    input logic [31:0] x,
    output logic [31:0] y
    );

    function [31:0] shift;
        input signed [31:0] x;
        input [1:0] sh;
        input [4:0] shamt5;
        begin
            case (sh)
                // LSL: 論理左シフト
                2'b00: shift = x << shamt5;
                // LSR: 論理右シフト
                2'b01: shift = x >> shamt5;
                // ASR: 算術右シフト
                2'b10: shift = x >>> shamt5;
                // ROR: 右回転
                2'b11: shift = (x >> shamt5) | (x << (32 - shamt5));

            endcase
        end
    endfunction

    assign y = shift(x, sh, shamt5);
endmodule
