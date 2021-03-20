module MainDecoder
    (
    input logic [1:0] op,
    input logic funct_5, funct_0,
    output logic branch, mem_to_reg, mem_w, alu_src, reg_w, alu_op,
    output logic [1:0] imm_src,
    output logic [2:0] reg_src
    );

    logic [10:0] controls; // {branch, mem_to_reg, mem_w, alu_src, imm_src, reg_w, reg_src, alu_op}

    always_comb begin
        case (op)
            2'b00: controls = (funct_5) ? 11'b0_0_0_1_00_1_000_1 : 11'b0_0_0_0_00_1_100_1; // DP Imm : Reg
            2'b01: controls = (funct_0) ? 11'b0_1_0_1_01_1_000_0 : 11'b0_0_1_1_01_0_010_0; // LDR : STR
            2'b10: controls = 11'b1_0_0_1_10_0_001_0; // B
            default: controls = 11'bx;
        endcase
    end

    assign {branch, mem_to_reg, mem_w, alu_src, imm_src, reg_w, reg_src, alu_op} = controls;
endmodule
