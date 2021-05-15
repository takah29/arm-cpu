module CondLogic
    (
    input logic clk, reset,
    input logic pcs, reg_w3, reg_w1, mem_w, no_write,
    input logic [1:0] flag_w,
    input logic [3:0] cond, cond_flags,
    output logic pc_src, reg_write3, reg_write1, mem_write, carry
    );

    logic cond_ex;
    logic [2:0] flag_write, flag_w_dec;
    logic [3:0] flags;

    always_comb begin
        case (flag_w)
            2'b00: flag_w_dec = 3'b000;
            2'b01: flag_w_dec = 3'b100;
            2'b10: flag_w_dec = 3'b110;
            2'b11: flag_w_dec = 3'b111;
        endcase
    end

    assign flag_write = flag_w_dec & {3{cond_ex}};

    Flopenr #(2) nv_flags_flopenr(.clk, .reset, .en(flag_write[2]), .d(cond_flags[3:2]), .q(flags[3:2]));
    Flopenr #(1) c_flags_flopenr(.clk, .reset, .en(flag_write[1]), .d(cond_flags[1]), .q(flags[1]));
    Flopenr #(1) v_flags_flopenr(.clk, .reset, .en(flag_write[0]), .d(cond_flags[0]), .q(flags[0]));

    logic n, z, c, v;
    assign {n, z, c, v} = flags;

    always_comb begin
        case (cond)
            4'b0000: cond_ex = z; // EQ
            4'b0001: cond_ex = ~z; // NE
            4'b0010: cond_ex = c; // CS/HS
            4'b0011: cond_ex = ~c; // CC/LO
            4'b0100: cond_ex = n; // MI
            4'b0101: cond_ex = ~n; // PL
            4'b0110: cond_ex = v; // VS
            4'b0111: cond_ex = ~v; // VC
            4'b1000: cond_ex = ~z & c; // HI
            4'b1001: cond_ex = z | ~c; // LS
            4'b1010: cond_ex = ~(n ^ v); // GE
            4'b1011: cond_ex = (n ^ v); // LT
            4'b1100: cond_ex = ~z & ~(n ^ v); // GT
            4'b1101: cond_ex = z | (n ^ v); // LE
            4'b1110: cond_ex = 1'b1; // AL
            default: cond_ex = 1'bx; // not defined
        endcase
    end

    assign pc_src = pcs & cond_ex;
    assign reg_write3 = reg_w3 & cond_ex & ~no_write;
    assign reg_write1 = reg_w1 & cond_ex & ~no_write;
    assign mem_write = mem_w & cond_ex;
    assign carry = c;
endmodule
