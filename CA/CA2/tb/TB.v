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

  // ============================================
  // DEBUG: Track controller state and PC
  // ============================================
  always @(posedge clk) begin
    if (!rst) begin
      $display("[%0t] PC=0x%h  State=%0d  IR=0x%h  zero=%b sign=%b  A=0x%h B=0x%h ALUOut=0x%h",
               $time, processor.datapath.program_counter.pc, processor.controller.state,
               processor.datapath.Instruction, processor.datapath.zero, processor.datapath.sign,
               processor.datapath.AOut, processor.datapath.BOut, processor.datapath.ALUOut);
    end
  end

  // ============================================
  // DEBUG: Track PC values over time
  // ============================================
  reg [31:0] pc_log[0:99];
  integer pc_count = 0;
  reg prev_pc_valid = 0;
  reg [31:0] prev_pc;

  always @(posedge clk) begin
    if (!rst) begin
      if (!prev_pc_valid || processor.datapath.program_counter.pc != prev_pc) begin
        if (pc_count < 100) begin
          pc_log[pc_count] = processor.datapath.program_counter.pc;
          pc_count = pc_count + 1;
        end
        prev_pc = processor.datapath.program_counter.pc;
        prev_pc_valid = 1;
      end
    end
  end

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

    // Quick check after reset
    #10;
    $display("PC after first fetch: 0x%h", processor.datapath.program_counter.pc);
    $display("IR after first fetch: 0x%h", processor.datapath.Instruction);
    #50;
    $display("PC after a few cycles: 0x%h", processor.datapath.program_counter.pc);
    $display("IR after a few cycles: 0x%h", processor.datapath.Instruction);

    // Wait for initial fetch
    #10;

    // Print initial array (data is at word addresses 256-265 to separate from code)
    $display("Initial array (at word addresses 256-265):");
    for (i = 0; i < 10; i = i + 1) begin
      // Access memory at data section (word address 256 + i)
      actual_value = processor.datapath.memory.mem[256+i];
      $display("  array[%0d] = %0d (at mem[%0d])", i, actual_value, 256 + i);
    end

    $display("");
    $display("Executing sorting program...");
    $display("(Each instruction takes 3-5 clock cycles in multicycle)");
    $display("");

    // Run program - multicycle needs more cycles per instruction
    // 14 instructions × ~4 cycles = ~56 cycles, use 500 to be safe
    repeat (500) @(posedge clk);

    // ============================================
    // DEBUG: Print PC trace
    // ============================================
    $display("");
    $display("PC trace (first 30 values):");
    for (i = 0; i < 30 && i < pc_count; i = i + 1) begin
      $display("  [%0d] PC = 0x%h", i, pc_log[i]);
    end
    $display("Total PC changes: %0d", pc_count);
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
