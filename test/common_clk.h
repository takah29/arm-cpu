parameter CYCLE = 100;
parameter HALF_CYCLE = 50;

logic clk;

always begin
    clk = 1'b1;
    #HALF_CYCLE;
    clk = 1'b0;
    #HALF_CYCLE;
end
