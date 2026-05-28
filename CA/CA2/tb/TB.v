`timescale 1ns / 1ns

module TestBench ();
  reg clk = 1'b0;
  reg rst = 1'b0;
  integer test_number;
  integer passed_tests;
  integer failed_tests;
  integer i;
  reg signed [31:0] actual_value;

  // Expected sorted array (ascending order)
  reg signed [31:0] expected[0:9];
  initial begin
    expected[0] = 1;
    expected[1] = 2;
    expected[2] = 3;
    expected[3] = 4;
    expected[4] = 5;
    expected[5] = 6;
    expected[6] = 7;
    expected[7] = 8;
    expected[8] = 9;
    expected[9] = 10;
  end

  // Instantiate RISC-V processor
  Processor processor (
      .clk(clk),
      .rst(rst)
  );

  // Clock generation
  always #5 clk = ~clk;

  // ============================================
  // Waveform Dumping - VCD File Generation
  // ============================================
  initial begin
    $dumpfile("riscv_waveform.vcd");
    $dumpvars(0, TestBench);
    $display("Waveform dumping to 'riscv_waveform.vcd'");
  end

  // Cycle-by-cycle logging
  integer cycle_count;
  always @(posedge clk) begin
    if (!rst) begin
      cycle_count = cycle_count + 1;
      $display("========================================");
      $display("Cycle %0d (Time=%0t ns)", cycle_count, $time);
      $display("PC: %0d (0x%08h)", $signed(processor.datapath.old_pc_reg.q),
               processor.datapath.old_pc_reg.q);
      $display("Instruction: %0d (0x%08h)", $signed(processor.datapath.IReg.q),
               processor.datapath.IReg.q);
      $display("");
      $display("Register File (decimal):");
      for (i = 0; i < 32; i = i + 4) begin
        $display("  x%0d=%-12d  x%0d=%-12d  x%0d=%-12d  x%0d=%-12d", i,
                 $signed(processor.datapath.RF.regs[i]), i + 1,
                 $signed(processor.datapath.RF.regs[i+1]), i + 2,
                 $signed(processor.datapath.RF.regs[i+2]), i + 3,
                 $signed(processor.datapath.RF.regs[i+3]));
      end
      $display("========================================");
    end
  end

  // Test sequence
  initial begin
    test_number  = 0;
    passed_tests = 0;
    failed_tests = 0;
    cycle_count  = 0;

    $display("========================================");
    $display("    RISC-V Sorting Test");
    $display("========================================");
    $display("");

    // Reset the processor
    $display("Resetting processor...");
    rst = 1;
    #10;
    rst = 0;
    $display("Reset completed");
    $display("");

    // Print instructions in memory once
    $display("Instructions in memory [64-84]:");
    for (i = 64; i < 85; i = i + 4) begin
      $display("  mem[%0d-%0d] = %02h %02h %02h %02h", i, i + 3,
               processor.datapath.memory.mem[i+3], processor.datapath.memory.mem[i+2],
               processor.datapath.memory.mem[i+1], processor.datapath.memory.mem[i]);
    end

    // Print initial array once
    $display("");
    $display("Initial array (decimal):");
    for (i = 0; i < 10; i = i + 1) begin
      actual_value = processor.datapath.memory.mem[i];
      $display("  array[%0d] = %0d", i, actual_value);
    end

    $display("");
    $display("Executing...");

    // Run program for limited cycles for debugging
    repeat (5000) @(posedge clk);

    $display("");
    $display("=== DEBUG STOP AFTER 500 CYCLES ===");
    $display("");
    $display("Sorted array (decimal):");

    for (i = 0; i < 10; i = i + 1) begin
      actual_value = processor.datapath.memory.mem[i];
      $display("  array[%0d] = %0d (expected %0d)", i, actual_value, expected[i]);

      if (actual_value == expected[i]) begin
        passed_tests = passed_tests + 1;
      end else begin
        failed_tests = failed_tests + 1;
      end
    end

    // Final results
    $display("");
    $display("========================================");
    $display("    Test Results Summary");
    $display("========================================");
    $display("Array Elements Tested: 10");
    $display("Passed: %0d", passed_tests);
    $display("Failed: %0d", failed_tests);
    $display("========================================");

    if (failed_tests == 0) begin
      $display("ALL TESTS PASSED!");
    end else begin
      $display("SOME TESTS FAILED!");
    end

    #20;
    $stop;
  end

  // Watchdog timer
  initial begin
    // #100000;
    $display("");
    $display("TIMEOUT: Simulation stopped");
    // $stop;
  end

endmodule
