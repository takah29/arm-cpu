module Extend
    (
    input logic [23:0] instr_imm,
    input logic [1:0] imm_src,
    output logic [31:0] ext_imm
    );

    function [31:0] ext;
        input [23:0] instr_imm;
        input [1:0] imm_src;
        logic [31:0] tmp;
        begin
            case (imm_src)
                // データ処理命令用8ビット直値
                2'b00: begin
                    tmp = {24'b0, instr_imm[7:0]};
                    ext = (tmp >> (2 * instr_imm[11:8])) | (tmp << (32 - 2 * instr_imm[11:8]));
                end
                // メモリ命令用12ビット直値
                2'b01: ext = {20'b0, instr_imm[11:0]};
                // B命令用24ビット直値
                2'b10: ext = {{6{instr_imm[23]}}, instr_imm, 2'b00};
                default: ext = 32'bx;
            endcase
        end
    endfunction

    assign ext_imm = ext(instr_imm, imm_src);
endmodule
