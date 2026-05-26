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

  // Instantiate the multicycle Processor
  Processor processor (
      .clk(clk),
      .rst(rst)
  );

  // Clock generation (slower for multicycle - 10ns period)
  always #5 clk = ~clk;

  // Test sequence
  initial begin
    test_number  = 0;
    passed_tests = 0;
    failed_tests = 0;

    $display("========================================");
    $display("    RISC-V Multicycle Sorting Test");
    $display("========================================");
    $display("");

    // Reset the processor
    $display("Resetting processor...");
    rst = 1'b1;
    #20;
    rst = 1'b0;
    $display("Reset completed");
    $display("");

    // Wait for initial fetch
    #10;

    // Print initial array (data is at word addresses 256-265 to separate from code)
    $display("Initial array (at word addresses 256-265):");
    for (i = 0; i < 10; i = i + 1) begin
      // Access memory at data section (word address 256 + i)
      actual_value = processor.datapath.memory.mem[256 + i];

      $display("  array[%0d] = %0d (at mem[%0d])", i, actual_value, 256 + i);
    end

    $display("");
    $display("Executing sorting program...");
    $display("(Each instruction takes 3-5 clock cycles in multicycle)");
    $display("");

    // Run program - multicycle needs more cycles per instruction
    // 14 instructions × ~4 cycles = ~56 cycles, use 500 to be safe
    repeat (500) @(posedge clk);

    $display("");
    $display("Sorted array:");

    // Check sorted array
    for (i = 0; i < 10; i = i + 1) begin
      actual_value = processor.datapath.memory.mem[256+i];

      $display("  array[%0d] = %0d (expected %0d)", i, actual_value, expected[i]);

      if (actual_value === expected[i]) begin
        passed_tests = passed_tests + 1;
      end else begin
        failed_tests = failed_tests + 1;
        $display("    FAIL: Element %0d mismatch!", i);
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

    $stop;
  end

  // Watchdog timer (longer for multicycle)
  initial begin
    #100000;
    $display("");
    $display("TIMEOUT: Simulation stopped (check for infinite loops)");
    $display("PC = 0x%h", processor.datapath.program_counter.pc);
    $stop;
  end

endmodule
