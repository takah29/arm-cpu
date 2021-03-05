module MainDecoder
    (
    input logic [1:0] op,
    input logic funct_5, funct_0,
    output logic branch, mem_to_reg, mem_w, alu_src, reg_w, alu_op,
    output logic [1:0] imm_src, reg_src
    );

    logic [9:0] controls; // {branch, mem_to_reg, mem_w, alu_src, imm_src, reg_w, reg_src, alu_op}

    always_comb begin
        case (op)
            2'b00: controls = (funct_5) ? 10'b0001001001 : 10'b0000001001; // DP Imm : Reg
            2'b01: controls = (funct_0) ? 10'b0101011000 : 10'b0011010100; // LDR : STR
            2'b10: controls = 10'b1001100010; // B
            default: controls = 10'bx;
        endcase
    end

    assign {branch, mem_to_reg, mem_w, alu_src, imm_src, reg_w, reg_src, alu_op} = controls;
endmodule
