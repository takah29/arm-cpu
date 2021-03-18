module AluDecoder
    (
    input logic alu_op, s,
    input logic [3:0] cmd,
    output logic no_write,
    output logic [1:0] alu_ctl, flag_w
    );

    always_comb begin
        if (alu_op) begin
            case (cmd)
                4'b0100: {alu_ctl, no_write} = 3'b000; // ADD
                4'b0010: {alu_ctl, no_write} = 3'b010; // SUB
                4'b0000: {alu_ctl, no_write} = 3'b100; // AND
                4'b1100: {alu_ctl, no_write} = 3'b110; // OR
                4'b1010: {alu_ctl, no_write} = 3'b011; // CMP
                4'b1000: {alu_ctl, no_write} = 3'b101; // TST
                default: {alu_ctl, no_write} = 3'bx; // not defined
            endcase

            flag_w[1] = s;
            flag_w[0] = s & (alu_ctl == 2'b00 | alu_ctl == 2'b01);
        end else begin
            alu_ctl = 2'b00;
            flag_w = 2'b00;
            no_write = 1'b0;
        end
    end
endmodule
