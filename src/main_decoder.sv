module MainDecoder
    (
    input logic [1:0] op,
    input logic [5:0] funct,
    input logic [3:0] instr74,
    output logic branch, mem_to_reg, mem_w, alu_src, reg_w3, reg_w1, alu_op, reg_src, post_idx, mult,
    output logic [1:0] imm_src
    );

    logic [11:0] controls; // {branch, mem_to_reg, mem_w, alu_src, imm_src, reg_w3, reg_w1, reg_src, alu_op, post_idx, mult}

    function [11:0] dp_controls(input [5:0] funct, input [3:0] instr74);
        casex ({funct, instr74})
            10'b0100100001: dp_controls = 12'b1_0_0_0_00_0_0_0_0_0_0; // BX
            10'b000XXX1001: dp_controls = 12'b0_0_0_0_00_0_1_0_0_0_1; // DP Multiply (32-bit)
            10'b001XXX1001: dp_controls = 12'b0_0_0_0_00_1_1_0_0_0_1; // DP Multiply (64-bit)
            10'b0XXXXXXXXX: dp_controls = 12'b0_0_0_0_00_1_0_0_1_0_0; // DP Reg
            10'b1XXXXXXXXX: dp_controls = 12'b0_0_0_1_00_1_0_0_1_0_0; // DP Imm
            // default: dp_controls = 12'bx;
        endcase
    endfunction

    function [11:0] mem_controls(input [5:0] funct);
        casex (funct)
            6'b01XX00: mem_controls = 12'b0_0_1_1_01_0_0_0_0_0_0; // STR (Imm)
            6'b11XX00: mem_controls = 12'b0_0_1_0_01_0_0_0_0_0_0; // STR (Reg)
            6'b00XX00: mem_controls = 12'b0_0_1_1_01_0_1_0_0_1_0; // STR (Imm, PostIdx)
            6'b10XX00: mem_controls = 12'b0_0_1_0_01_0_1_0_0_1_0; // STR (Reg, PostIdx)
            6'b01XX10: mem_controls = 12'b0_0_1_1_01_0_1_0_0_0_0; // STR (Imm, PreIdx)
            6'b11XX10: mem_controls = 12'b0_0_1_0_01_0_1_0_0_0_0; // STR (Reg, PreIdx)
            6'b01XX01: mem_controls = 12'b0_1_0_1_01_1_0_0_0_0_0; // LDR (Imm)
            6'b11XX01: mem_controls = 12'b0_1_0_0_01_1_0_0_0_0_0; // LDR (Reg)
            6'b00XX01: mem_controls = 12'b0_1_0_1_01_1_1_0_0_1_0; // LDR (Imm, PostIdx)
            6'b10XX01: mem_controls = 12'b0_1_0_0_01_1_1_0_0_1_0; // LDR (Reg, PostIdx)
            6'b01XX11: mem_controls = 12'b0_1_0_1_01_1_1_0_0_0_0; // LDR (Imm, PreIdx)
            6'b11XX11: mem_controls = 12'b0_1_0_0_01_1_1_0_0_0_0; // LDR (Reg, PreIdx)
            default: mem_controls = 12'bx;
        endcase
    endfunction

    always_comb begin
        case (op)
            2'b00: controls = dp_controls(funct, instr74); // DP
            2'b01: controls = mem_controls(funct); // Memory
            2'b10: controls = 12'b1_0_0_1_10_0_0_1_0_0_0; // B
            default: controls = 12'bx;
        endcase
    end

    assign {branch, mem_to_reg, mem_w, alu_src, imm_src, reg_w3, reg_w1, reg_src, alu_op, post_idx, mult} = controls;
endmodule
