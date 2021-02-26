module Extend
    (
    input logic [11:0] instr_imm,
    input logic imm_src,
    output logic [31:0] ext_imm
    );

    function [31:0] ext;
        input [11:0] instr_imm;
        input imm_src;
        begin
            case (imm_src)
                // データ処理命令用8ビット直値
                1'b0: ext = {24'b0, instr_imm[7:0]};
                // メモリ命令用12ビット直値
                1'b1: ext = {20'b0, instr_imm};
            endcase
        end
    endfunction

    assign ext_imm = ext(instr_imm, imm_src);
endmodule
