`timescale 1ns / 1ns

module TB ();
  reg clk = 1'b0;
  reg rst = 1'b0;
  integer passed, failed;

  RISC_V risc_v (
      .clk(clk),
      .rst(rst)
  );

  always #1 clk = ~clk;

  task check_reg;
    input [4:0] reg_num;
    input [31:0] expected;
    input [80*8:1] test_name;

    begin
      #2;
      if (risc_v.datapath.register_file.reg_file[reg_num] === expected) begin
        $display("  PASS: %s", test_name);
        passed = passed + 1;
      end else begin
        $display("  FAIL: %s - Expected %d, Got %d", test_name, expected,
                 risc_v.datapath.register_file.reg_file[reg_num]);
        failed = failed + 1;
      end
    end
  endtask

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
        $display("  FAIL: %s - Expected %d, Got %d", test_name, expected,
                 risc_v.datapath.data_memory.data_mem[addr]);
        failed = failed + 1;
      end
    end
  endtask

  initial begin
    passed = 0;
    failed = 0;

    $display("============================================");
    $display("  RISC-V Complete Instruction Test");
    $display("============================================");
    $display("");

    // Reset
    rst = 1;
    #10;
    rst = 0;
    #10;

    $display("1. Arithmetic Instructions");
    $display("--------------------------");
    check_reg(0, 0, "x0 always zero");
    #10 check_reg(1, 10, "ADDI: x1 = 10");
    #10 check_reg(2, -5, "ADDI negative: x2 = -5");
    #10 check_reg(3, 5, "ADD: x3 = x1+x2 = 5");
    #10 check_reg(4, 15, "SUB: x4 = x1-x2 = 15");

    $display("");
    $display("2. Logical Instructions");
    $display("--------------------------");
    #10 check_reg(5, 2, "ANDI: 10 & 3 = 2");
    #10 check_reg(6, 14, "ORI: 10 | 12 = 14");
    #10 check_reg(7, 5, "XORI: 10 ^ 15 = 5");

    $display("");
    $display("3. Comparison Instructions");
    $display("--------------------------");
    #10 check_reg(8, 1, "SLTI: -5 < 0 = 1 (true)");
    #10 check_reg(9, 0, "SLTI: 10 < 0 = 0 (false)");

    $display("");
    $display("4. Memory Instructions");
    $display("--------------------------");
    #10 check_mem(0, 10, "SW: mem[0] = 10");
    #10 check_reg(10, 10, "LW: x10 = mem[0] = 10");

    $display("");
    $display("5. Branch Instructions");
    $display("--------------------------");
    #10 check_reg(11, 20, "BEQ taken: x11 = 20");
    #10 check_reg(12, 30, "BNE taken: x12 = 30");
    #10 check_reg(13, 40, "BLT taken: x13 = 40");
    #10 check_reg(14, 50, "BGE taken: x14 = 50");

    $display("");
    $display("6. Jump Instructions");
    $display("--------------------------");
    #10 check_reg(31, 116, "JAL: x31 = return address (PC+4)");
    #10 check_reg(2, 15, "JAL target reached: x2 = 15");
    #10 check_reg(30, 156, "JALR: x30 = return address");
    #10 check_reg(3, 20, "JALR target reached: x3 = 20");
    #10 check_reg(29, 25, "JALR x0: x29 = 25");

    // Results
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
