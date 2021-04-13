module InstructionMemoryTestbench();
    logic clk;
    logic [31:0] address;
    logic [31:0] read_data, rd_expected;
    integer errors, vectornum;
    logic [31:0] testvectors[0:4095];

    InstructionMemory dut(.address, .read_data);

    always begin
        clk = 0;
        #5;
        clk = 1;
        #5;
    end

    initial begin
        $readmemb("programs/program.dat", testvectors);
        vectornum = 0;
        errors = 0;
        address = 0;
        foreach (testvectors[i]) begin
            dut.ram[i] = testvectors[i];
        end
    end

    always @(posedge clk) begin
        #1;
        rd_expected = testvectors[vectornum];
    end

    always @(negedge clk) begin
        if (read_data !== rd_expected) begin
            $display("Error: input = (%h)", address);
            $display(" outputs = %h (%h expected)", read_data, rd_expected);
            errors = errors + 1;
        end
        vectornum = vectornum + 1;
        if (testvectors[vectornum] === 32'bx) begin
            $display("%d test completed with %d errors", vectornum, errors);
            $finish;
        end
        address = address + 4;
    end
endmodule
