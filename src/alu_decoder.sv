module AluDecoder
    (
    input logic alu_op, s,
    input logic [3:0] cmd,
    output logic no_write, shift,
    output logic [1:0] alu_ctl, flag_w
    );

    always_comb begin
        if (alu_op) begin
            case (cmd)
                4'b0100: {alu_ctl, no_write, shift} = 4'b0000; // ADD
                4'b0010: {alu_ctl, no_write, shift} = 4'b0100; // SUB
                4'b0000: {alu_ctl, no_write, shift} = 4'b1000; // AND
                4'b1100: {alu_ctl, no_write, shift} = 4'b1100; // OR
                4'b1010: {alu_ctl, no_write, shift} = 4'b0110; // CMP
                4'b1011: {alu_ctl, no_write, shift} = 4'b0010; // CMN
                4'b1000: {alu_ctl, no_write, shift} = 4'b1010; // TST
                4'b1101: {alu_ctl, no_write, shift} = 4'bxx01; // LSL
                default: {alu_ctl, no_write, shift} = 4'bx; // not defined
            endcase

            flag_w[1] = s;
            flag_w[0] = s & (alu_ctl === 2'b00 | alu_ctl === 2'b01);
        end else begin
            alu_ctl = 2'b00;
            flag_w = 2'b00;
            no_write = 1'b0;
            shift = 1'b0;
        end
    end
endmodule
