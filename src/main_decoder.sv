module MainDecoder
    (
    input logic [1:0] op,
    input logic funct_5, funct_0,
    output logic branch, mem_to_reg, mem_w, alu_src, reg_w, alu_op, reg_src,
    output logic [1:0] imm_src
    );

    logic [9:0] controls; // {branch, mem_to_reg, mem_w, alu_src, imm_src, reg_w, reg_src, alu_op}
    logic [1:0] funct_50;
    assign funct_50 = {funct_5, funct_0};

    function [9:0] dp_controls(input [5:0] funct);
        casex (funct_50)
            2'b0?: dp_controls = 10'b0_0_0_0_00_1_0_1; // DP Reg
            2'b1?: dp_controls = 10'b0_0_0_1_00_1_0_1; // DP Imm
            default: dp_controls = 10'bx;
        endcase
    endfunction

    function [9:0] mem_controls(input [5:0] funct);
        casex (funct_50)
            2'b?0: mem_controls = 10'b0_0_1_1_01_0_0_0; // STR (Imm)
            2'b01: mem_controls = 10'b0_1_0_1_01_1_0_0; // LDR (Imm)
            2'b11: mem_controls = 10'b0_1_0_0_01_1_0_0; // LDR (Reg)
            default: mem_controls = 10'bx;
        endcase
    endfunction

    always_comb begin
        case (op)
            2'b00: controls = dp_controls(funct_50); // DP
            2'b01: controls = mem_controls(funct_50); // Memory
            2'b10: controls = 10'b1_0_0_1_10_0_1_0; // B
            default: controls = 10'bx;
        endcase
    end

    assign {branch, mem_to_reg, mem_w, alu_src, imm_src, reg_w, reg_src, alu_op} = controls;
endmodule
