module Swap
    #(parameter N = 32)
    (
    input logic [N - 1:0] x0, x1,
    input logic en,
    output logic [N - 1:0] y0, y1
    );

    assign y0 = en ? x1 : x0;
    assign y1 = ~en ? x1 : x0;
endmodule
