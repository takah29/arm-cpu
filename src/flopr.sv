module flopr #(parameter N = 32)
    (
    input logic clk,
    input logic reset,
    input logic [N - 1:0] d,
    output logic [N - 1:0] q
    );

    always_ff @(posedge clk, posedge reset) begin
        if (reset)begin
            q <= 0;
        end else begin
            q <= d;
        end
    end
endmodule
