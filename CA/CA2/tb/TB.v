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
  always #50 clk = ~clk;

  // ============================================
  // Waveform Dumping - VCD File Generation
  // ============================================
  initial begin
    $dumpfile("riscv_waveform.vcd");  // Name of the VCD file
    $dumpvars(0, TestBench);  // Dump all signals in TestBench
    // Alternative: Dump specific hierarchy levels
    // $dumpvars(1, risc_v);             // Dump only the processor and below
    // $dumpvars(2, risc_v.dp);          // Dump datapath and below
    $display("Waveform dumping to 'riscv_waveform.vcd'");
  end

  // Test sequence
  initial begin
    test_number  = 0;
    passed_tests = 0;
    failed_tests = 0;

    $display("========================================");
    $display("    RISC-V Sorting Test");
    $display("========================================");
    $display("");

    // Reset the processor
    $display("Resetting processor...");
    rst = 1;
    #100;
    rst = 0;
    $display("Reset completed");
    $display("");

    // Print initial array
    $display("Initial array:");
    for (i = 0; i < 10; i = i + 1) begin
      actual_value = processor.datapath.memory.mem[i];

      $display("  array[%0d] = %0d", i, actual_value);
    end

    $display("");
    $display("Executing...");

    // Run program
    repeat (500) @(posedge clk);

    $display("");
    $display("Sorted array:");

    // Check sorted array
    for (i = 0; i < 10; i = i + 1) begin
      actual_value = processor.datapath.memory.mem[i];

      $display("  array[%0d] = %0d (expected %0d)", i, actual_value, expected[i]);

      if (actual_value == expected[i]) begin
        passed_tests = passed_tests + 1;
      end else begin
        failed_tests = failed_tests + 1;
        // $display("    FAIL: Element %0d mismatch!", i);
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

    // Allow some time for waveform to capture final state
    #20;
    $stop;
  end

  // Watchdog timer
  initial begin
    #120000;
    $display("");
    $display("TIMEOUT: Simulation stopped");
    $stop;
  end

endmodule
