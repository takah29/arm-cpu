module TopTestbench;
    parameter HALF_CYCLE = 5;

    logic clk, reset;
    logic [31:0] write_data, data_memory_addr;
    logic mem_write;
    integer errors, vectornum;
    logic [31:0] testvectors[0:1048575]; // 4MB

    Top dut(
    .clk,
    .reset,
    .write_data,
    .data_memory_addr,
    .mem_write
    );

    task show_regs;
        for (int i = 0; i < 15; i++) begin
            $write("R%1d=%h, ", i, dut.arm_cpu.data_path.register_file.reg_file[i]);
        end
        $display("R15=%h", dut.arm_cpu.data_path.register_file.r15);
    endtask

    // シミュレーション結果出力
    // initial begin
    //   // 波形データ出力
    //   $dumpfile("wave.vcd");
    //   // 全てのポートを波形データに出力
    //   $dumpvars(0, dut);
    // end

    initial begin
        reset <= 1; # 1; reset <= 0;
        $readmemb("programs/test_program.dat", testvectors);
        vectornum = 0;
        errors = 0;

        // プログラムを命令メモリとデータメモリに設定
        foreach (testvectors[i]) begin
            dut.imem.ram[i] = testvectors[i];
            dut.dmem.ram[i] = testvectors[i];
        end
    end

    always begin
        clk <= 1;
        #HALF_CYCLE;
        clk <= 0;
        #HALF_CYCLE;
    end

    always @(negedge clk) begin
        $write("ADDR (%2h) Instr=%h: ", dut.arm_cpu.data_path.pc, dut.arm_cpu.data_path.instr);
        show_regs;
        if (mem_write) begin
            if (data_memory_addr == 100 & write_data == 7) begin
                $display("Simulation succeeded.");
                $finish;
            end else if (data_memory_addr !== 96) begin
                $display("Simulation failed.");
                $display(dut.arm_cpu.data_path.reg_addr1, dut.arm_cpu.data_path.src_b);
                $finish;
            end
        end
    end

endmodule
