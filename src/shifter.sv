module Shifter
    (
    input logic [1:0] shift_type,
    input logic [7:0] shift_num,
    input logic not_shift, instr4,
    input logic [31:0] x,
    input logic carry,
    output logic [31:0] shifter_operand,
    output logic shifter_carry_out
    );

    function [32:0] shift; // shift = {shifter_carry_out, shifter_operand}
        input signed [31:0] x;
        input carry;
        input [1:0] shift_type;
        input [7:0] shift_num;
        input instr4;
        begin
            logic [32:0] tmp;
            case (shift_type)
                2'b00: shift = {carry, x} << shift_num;  // LSL: 論理左シフト
                2'b01: begin // LSR: 論理右シフト
                    tmp = {x, carry} >> shift_num;
                    shift = {tmp[0], tmp[32:1]};
                end
                2'b10: begin // ASR: 算術右シフト
                    tmp = $signed({x, carry}) >>> shift_num;
                    shift = {tmp[0], tmp[32:1]};
                end
                2'b11: if ({shift_num[4:0], instr4} === 6'b00000_0) begin  // RRX: 拡張右回転
                    shift = {x[0], carry, x[31:1]};
                end else begin  // ROR: 右回転
                    if (shift_num == 0) begin
                        shift = {carry, x};
                    end else if (shift_num[4:0] == 0) begin
                        shift = {x[31], x};
                    end else begin // shift_num[4:0] > 0
                        shift = {x[shift_num[4:0] - 1], (x >> shift_num[4:0]) | (x << (32 - shift_num[4:0]))};
                    end

                end
            endcase
        end
    endfunction

    assign {shifter_carry_out, shifter_operand} = not_shift ? {carry, x} : shift(x, carry, shift_type, shift_num, instr4);
endmodule
