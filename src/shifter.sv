module Shifter
    (
    input logic [1:0] shift_type,
    input logic [4:0] shift_num,
    input logic [31:0] x,
    output logic [31:0] y
    );

    function [31:0] shift;
        input signed [31:0] x;
        input [1:0] shift_type;
        input [4:0] shift_num;
        begin
            case (shift_type)
                // LSL: 論理左シフト
                2'b00: shift = x << shift_num;
                // LSR: 論理右シフト
                2'b01: shift = x >> shift_num;
                // ASR: 算術右シフト
                2'b10: shift = x >>> shift_num;
                // ROR: 右回転
                2'b11: shift = (x >> shift_num) | (x << (32 - shift_num));

            endcase
        end
    endfunction

    assign y = shift(x, shift_type, shift_num);
endmodule
