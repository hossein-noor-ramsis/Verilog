`timescale 1ns / 1ns

module TB ();
  reg clk = 1'b0;
  reg rst = 1'b0;
  integer i;
  reg signed [31:0] actual_value;

  // Instantiate RISC-V processor
  RISC_V risc_v (
      .clk(clk),
      .rst(rst)
  );

  // Clock generation
  always #1 clk = ~clk;

  // Test sequence
  initial begin
    $display("========================================");
    $display("    RISC-V Simple Swap Test");
    $display("========================================");
    $display("");

    // Reset the processor
    $display("Resetting processor...");
    rst = 1'b1;
    #10;
    rst = 1'b0;
    $display("Reset completed");
    $display("");

    // Print initial array
    $display("Initial array:");
    for (i = 0; i < 10; i = i + 1) begin
      actual_value = risc_v.datapath.data_memory.data_mem[i];
      $display("  array[%0d] = %0d", i, actual_value);
    end

    $display("");
    $display("Executing swap of array[0] and array[1]...");
    $display("");

    // Run for enough cycles to complete the swap
    repeat (20) @(posedge clk);

    // Print final array
    $display("Final array:");
    for (i = 0; i < 10; i = i + 1) begin
      actual_value = risc_v.datapath.data_memory.data_mem[i];
      $display("  array[%0d] = %0d", i, actual_value);
    end

    $display("");
    $display("========================================");
    $display("    Swap Test Results");
    $display("========================================");

    // Check swap
    actual_value = risc_v.datapath.data_memory.data_mem[0];
    if (actual_value == -12) begin
      $display("array[0] = %0d: CORRECT (was 45, now -12)", actual_value);
    end else begin
      $display("array[0] = %0d: FAIL (expected -12)", actual_value);
    end

    actual_value = risc_v.datapath.data_memory.data_mem[1];
    if (actual_value == 45) begin
      $display("array[1] = %0d: CORRECT (was -12, now 45)", actual_value);
    end else begin
      $display("array[1] = %0d: FAIL (expected 45)", actual_value);
    end

    // Check that other elements are unchanged
    for (i = 2; i < 10; i = i + 1) begin
      actual_value = risc_v.datapath.data_memory.data_mem[i];
      $display(
          "array[%0d] = %0d: %s", i, actual_value,
          (i == 2 && actual_value == 89) || (i == 3 && actual_value == -3) || (i == 4 && actual_value == 67) || (i == 5 && actual_value == -99) || (i == 6 && actual_value == 23) || (i == 7 && actual_value == 0) || (i == 8 && actual_value == -55) || (i == 9 && actual_value == 14) ? "CORRECT" : "FAIL");
    end

    $display("========================================");
    $stop;
  end

  // Watchdog timer
  initial begin
    #1000;
    $display("");
    $display("TIMEOUT: Simulation stopped");
    $stop;
  end

endmodule
