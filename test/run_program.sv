module RunProgram;
    parameter HALF_CYCLE = 5;

    logic clk, reset;
    logic [31:0] write_data, data_memory_addr;
    logic mem_write;
    integer errors, vectornum;
    logic [31:0] testvectors[0:4095];

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
        $readmemh("programs/program.dat", testvectors);
        vectornum = 0;
        errors = 0;

        // プログラムを命令メモリとデータメモリに設定
        foreach (testvectors[i]) begin
            dut.imem.ram[i] = testvectors[i];
            dut.dmem.ram[i] = testvectors[i];
        end
        // 4バイトアライメントの最大値をSPとして設定する
        dut.arm_cpu.data_path.register_file.reg_file[13] = 4092;
    end

    always begin
        clk <= 1;
        #HALF_CYCLE;
        clk <= 0;
        #HALF_CYCLE;
    end

    always @(posedge clk) begin
        #1;
        $write("ADDR (%2h) Instr=%h: ", dut.arm_cpu.data_path.pc, dut.arm_cpu.data_path.instr);
        show_regs;
        // bx lrの場合は実行を終了する
        if (dut.arm_cpu.data_path.instr === 32'he12fff1e) begin
            $display("=== Data Memory ===");
            foreach (testvectors[i]) begin
                if (dut.dmem.ram[i] !== 32'hx) begin
                    $display("%8h: %8h", i * 4, dut.dmem.ram[i]);
                end
                    // disable loop_exit;
            end
            $display("===================");
            $display("Simulation finished.");
            $finish;
        end else if (dut.arm_cpu.data_path.instr === 32'hx) begin
            $display("Simulation failed.");
            $finish;
        end
    end

endmodule
