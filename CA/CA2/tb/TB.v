module TB_Processor;
  reg clk;
  reg rst;

  // Clock generation
  always #5 clk = ~clk;

  // Processor top module
  Processor processor (
      .clk(clk),
      .rst(rst)
  );

  integer cycle_count;

  // Test sequence
  initial begin
    clk = 0;
    rst = 1;
    cycle_count = 0;

    // Reset for a few cycles
    repeat (5) @(posedge clk);
    rst = 0;

    // Run for many cycles
    repeat (400) @(posedge clk);

    // Check results
    $display("\n===========================================");
    $display("         RISC-V Processor Test Results");
    $display("===========================================");
    $display("Total cycles: %d", cycle_count);
    $display("");

    // Display register values directly
    $display("Register values:");
    $display("x1  (ADDI 10)    = %d", processor.datapath.RF.regs[1]);
    $display("x2  (ADDI 20)    = %d", processor.datapath.RF.regs[2]);
    $display("x3  (ADD)        = %d", processor.datapath.RF.regs[3]);
    $display("x4  (SUB)        = %d", processor.datapath.RF.regs[4]);
    $display("x5  (AND)        = %d", processor.datapath.RF.regs[5]);
    $display("x6  (OR)         = %d", processor.datapath.RF.regs[6]);
    $display("x7  (XOR)        = %d", processor.datapath.RF.regs[7]);
    $display("x8  (SLT 10<20)  = %d", processor.datapath.RF.regs[8]);
    $display("x9  (SLT 20<10)  = %d", processor.datapath.RF.regs[9]);
    $display("x10 (SLTI 10<15) = %d", processor.datapath.RF.regs[10]);
    $display("x11 (ORI 0xFF)   = %d", processor.datapath.RF.regs[11]);
    $display("");

    // Check pass/fail
    check_reg(1, 10);
    check_reg(2, 20);
    check_reg(3, 30);
    check_reg(4, 10);
    check_reg(5, 0);
    check_reg(6, 30);
    check_reg(7, 30);
    check_reg(8, 1);
    check_reg(9, 0);
    check_reg(10, 1);
    check_reg(11, 255);

    $display("\n===========================================");
    $finish;
  end

  task check_reg;
    input [4:0] reg_num;
    input [31:0] expected;
    begin
      if (processor.datapath.RF.regs[reg_num] == expected)
        $display("PASS: x%0d = %d", reg_num, expected);
      else
        $display(
            "FAIL: x%0d = %d (expected %d)", reg_num, processor.datapath.RF.regs[reg_num], expected
        );
    end
  endtask

  // Cycle counter
  always @(posedge clk) begin
    if (!rst) begin
      cycle_count <= cycle_count + 1;
      // Print every 5 cycles
      if (cycle_count % 5 == 0) begin
        $display("[Cycle %0d] PC=%h", cycle_count, processor.datapath.program_counter.pc);
      end
    end
  end

  // // Waveform dump
  // initial begin
  //   $dumpfile("processor_tb.vcd");
  //   $dumpvars(0, TB_Processor);
  // end

endmodule
