module Swap
    #(parameter N = 32)
    (
    input logic [N - 1:0] d0, d1,
    input logic en,
    output logic [N - 1:0] y0, y1
    );

    assign y0 = en ? d1 : d0;
    assign y1 = ~en ? d1 : d0;
endmodule
