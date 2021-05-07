module Shifter
    (
    input logic [1:0] shift_type,
    input logic [7:0] shift_num,
    input logic not_shift,
    input logic [31:0] x,
    input logic carry,
    output logic [31:0] y,
    output logic c
    );

    function [31:0] shift;
        input signed [31:0] x;
        input carry;
        input [1:0] shift_type;
        input [7:0] shift_num;
        begin
            case (shift_type)
                2'b00: shift = x << shift_num;  // LSL: 論理左シフト
                2'b01: shift = x >> shift_num;  // LSR: 論理右シフト
                2'b10: shift = x >>> shift_num;  // ASR: 算術右シフト
                2'b11: if (shift_num[4:0] === 5'b00000) begin  // RRX: 拡張右回転
                    shift = {carry, x[31:1]};
                end else begin  // ROR: 右回転
                    shift = (x >> shift_num) | (x << (32 - shift_num[4:0]));
                end
            endcase
        end
    endfunction

    assign y = not_shift ? x : shift(x, carry, shift_type, shift_num);

    // RRX命令時にcフラグを置き換えるために使用する。それ以外では使用しない
    assign c = not_shift ? carry : x[0];
endmodule
