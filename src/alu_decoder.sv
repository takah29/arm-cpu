module AluDecoder
    (
    input logic alu_op, s, branch, mult,
    input logic [3:0] cmd,
    output logic no_write, not_alu, not_shift, swap, inv,
    output logic [2:0] alu_ctl,
    output logic [1:0] flag_w
    );

    always_comb begin
        if (alu_op) begin
            case (cmd)
                4'b0100: {alu_ctl, no_write, not_alu, not_shift, swap, inv} = 8'b000_0_0_0_0_0; // ADD
                4'b0010: {alu_ctl, no_write, not_alu, not_shift, swap, inv} = 8'b001_0_0_0_0_0; // SUB
                4'b0000: {alu_ctl, no_write, not_alu, not_shift, swap, inv} = 8'b010_0_0_0_0_0; // AND
                4'b1100: {alu_ctl, no_write, not_alu, not_shift, swap, inv} = 8'b011_0_0_0_0_0; // OR
                4'b0001: {alu_ctl, no_write, not_alu, not_shift, swap, inv} = 8'b110_0_0_0_0_0; // EOR
                4'b0101: {alu_ctl, no_write, not_alu, not_shift, swap, inv} = 8'b100_0_0_0_0_0; // ADC
                4'b0110: {alu_ctl, no_write, not_alu, not_shift, swap, inv} = 8'b101_0_0_0_0_0; // SBC
                4'b0011: {alu_ctl, no_write, not_alu, not_shift, swap, inv} = 8'b001_0_0_0_1_0; // RSB
                4'b0111: {alu_ctl, no_write, not_alu, not_shift, swap, inv} = 8'b101_0_0_0_1_0; // RSC
                4'b1110: {alu_ctl, no_write, not_alu, not_shift, swap, inv} = 8'b010_0_0_0_0_1; // BIC
                4'b1010: {alu_ctl, no_write, not_alu, not_shift, swap, inv} = 8'b001_1_0_0_0_0; // CMP
                4'b1011: {alu_ctl, no_write, not_alu, not_shift, swap, inv} = 8'b000_1_0_0_0_0; // CMN
                4'b1000: {alu_ctl, no_write, not_alu, not_shift, swap, inv} = 8'b010_1_0_0_0_0; // TST
                4'b1001: {alu_ctl, no_write, not_alu, not_shift, swap, inv} = 8'b110_1_0_0_0_0; // TEQ
                4'b1111: {alu_ctl, no_write, not_alu, not_shift, swap, inv} = 8'b0xx_0_1_0_0_1; // MVN
                4'b1101: {alu_ctl, no_write, not_alu, not_shift, swap, inv} = 8'b0xx_0_1_0_0_0; // LSL, LSR, ASR, ROR
                default: {alu_ctl, no_write, not_alu, not_shift, swap, inv} = 8'bx; // not defined
            endcase

            flag_w[1] = s;
            flag_w[0] = s & (alu_ctl === 3'b000 | alu_ctl === 3'b001 | alu_ctl === 3'b100 | alu_ctl === 3'b101);
        end else begin
            casex ({mult, branch, cmd ,s})
                7'b0_1_1001_0: {alu_ctl, flag_w, not_alu, not_shift} = 7'b000_00_1_1; // Branch (BX)
                7'b1_0_0XXX_1: {alu_ctl, flag_w, not_alu, not_shift} = 7'b000_10_0_0; // Multiply (S = 1)
                7'b0_0_X0XX_X: {alu_ctl, flag_w, not_alu, not_shift} = 7'b001_00_0_0; // Memory (SUB)
                default: {alu_ctl, flag_w, not_alu, not_shift} = 7'b000_00_0_0; // otherwise
            endcase
            no_write = 1'b0;
            swap = 1'b0;
            inv = 1'b0;
        end
    end
endmodule
