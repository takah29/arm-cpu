module CondLogic
    (
    input logic clk, reset,
    input logic pcs, reg_w, mem_w, no_write,
    input logic [1:0] flag_w,
    input logic [3:0] cond, alu_flags,
    output logic pc_src, reg_write, mem_write
    );

    logic cond_ex;
    logic [1:0] flag_write;
    logic [3:0] flags;

    assign flag_write = flag_w & {2{cond_ex}};

    Flopenr #(2) alu_flags_flopenr1(.clk, .reset, .en(flag_write[1]), .d(alu_flags[3:2]), .q(flags[3:2]));
    Flopenr #(2) alu_flags_flopenr0(.clk, .reset, .en(flag_write[0]), .d(alu_flags[1:0]), .q(flags[1:0]));

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
    assign reg_write = reg_w & cond_ex & ~no_write;
    assign mem_write = mem_w & cond_ex;
endmodule
