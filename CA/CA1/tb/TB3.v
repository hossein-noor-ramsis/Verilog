`timescale 1ns / 1ns

module TB ();
  reg clk = 1'b0;
  reg rst = 1'b0;
  integer passed, failed;
  integer i;

  RISC_V risc_v (
      .clk(clk),
      .rst(rst)
  );

  always #1 clk = ~clk;

  task check_mem;
    input [9:0] addr;
    input [31:0] expected;
    input [80*8:1] test_name;
    begin
      #2;
      if (risc_v.datapath.data_memory.data_mem[addr] === expected) begin
        $display("  PASS: %s", test_name);
        passed = passed + 1;
      end else begin
        $display("  FAIL: %s - Addr=%d, Expected=%d, Got=%d", test_name, addr, expected,
                 risc_v.datapath.data_memory.data_mem[addr]);
        failed = failed + 1;
      end
    end
  endtask

  initial begin
    passed = 0;
    failed = 0;

    $display("============================================");
    $display("  Test: Add 1 to all data memory values");
    $display("============================================");
    $display("");

    // Reset
    rst = 1;
    #10;
    rst = 0;
    #10;

    // Wait for program to finish (حدود 100 سیکل برای 10 تا داده)
    #200;

    $display("Checking memory values after adding 1:");
    $display("----------------------------------------");

    check_mem(0, 32'h00000006, "mem[0] should be 6");
    check_mem(4, 32'h0000000B, "mem[4] should be 11");
    check_mem(8, 32'h00000004, "mem[8] should be 4");
    check_mem(12, 32'h00000000, "mem[12] should be 0 (FF+1 overflow to 0)");
    check_mem(16, 32'h00000001, "mem[16] should be 1");
    check_mem(20, 32'h00000008, "mem[20] should be 8");
    check_mem(24, 32'hFFFFFFF7, "mem[24] should be -9");
    check_mem(28, 32'h00000002, "mem[28] should be 2");
    check_mem(32, 32'h00000003, "mem[32] should be 3");
    check_mem(36, 32'h00000005, "mem[36] should be 5");

    $display("");
    $display("============================================");
    $display("  Results: Passed=%d / Failed=%d", passed, failed);
    $display("============================================");

    if (failed == 0) $display("  ALL TESTS PASSED!");
    else $display("  %d TESTS FAILED!", failed);

    $stop;
  end

  initial begin
    #1000;
    $display("TIMEOUT!");
    $stop;
  end

endmodule
