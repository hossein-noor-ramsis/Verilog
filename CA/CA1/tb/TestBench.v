`timescale 1ns / 1ns

module TB ();
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
    expected[0] = -99;
    expected[1] = -55;
    expected[2] = -12;
    expected[3] = -3;
    expected[4] = 0;
    expected[5] = 14;
    expected[6] = 23;
    expected[7] = 45;
    expected[8] = 67;
    expected[9] = 89;
  end

  // Instantiate RISC-V processor
  RISC_V risc_v (
      .clk(clk),
      .rst(rst)
  );

  // Clock generation
  always #1 clk = ~clk;

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
    rst = 1'b1;
    #10;
    rst = 1'b0;
    $display("Reset completed");
    $display("");

    // // Debug: Show first 40 instructions
    // $display("First 40 instructions:");
    // repeat (40) begin
    //   @(negedge clk);
    //   $display("PC=%h Inst=%h RS1=%d RS2=%d RegWrite=%b MemWrite=%b Branch=%b",
    //            risc_v.datapath.program_counter.pc_current, risc_v.datapath.instruction,
    //            risc_v.datapath.rs1_addr, risc_v.datapath.rs2_addr, risc_v.datapath.reg_write,
    //            risc_v.datapath.mem_write, (risc_v.datapath.pc_src != 0));
    // end
    // $stop;

    // Print initial array
    $display("Initial array:");
    for (i = 0; i < 10; i = i + 1) begin
      actual_value = risc_v.datapath.data_memory.data_mem[i];

      $display("  array[%0d] = %0d", i, actual_value);
    end

    $display("");
    $display("Executing...");

    // Run program
    repeat (1000) @(posedge clk);

    $display("");
    $display("Sorted array:");

    // Check sorted array
    for (i = 0; i < 10; i = i + 1) begin
      actual_value = risc_v.datapath.data_memory.data_mem[i];

      $display("  array[%0d] = %0d (expected %0d)", i, actual_value, expected[i]);

      if (actual_value == expected[i]) begin
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

  // Watchdog timer
  initial begin
    #10000;
    $display("");
    $display("TIMEOUT: Simulation stopped");
    $stop;
  end

endmodule
