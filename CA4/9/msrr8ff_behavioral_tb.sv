`timescale 1ns / 1ns

module msrr8ff_behavioral_tb;

  logic clk = 0;
  logic rst = 1;
  logic [1:0] mode = 2'b00;
  logic sIn = 0;
  logic inz = 0;
  logic [7:0] Q;

  // Device under test
  msrr8ff_behavioral dut (
      .clk(clk),
      .rst(rst),
      .mode(mode),
      .inz(inz),
      .sIn(sIn),
      .Q(Q)
  );

  // simple clock
  always #50 clk = ~clk;

  initial begin
    $display("Starting simple testbench...");
    rst = 0;
    #100;

    // Test 2: reset = 1
    rst = 1;
    #100;

    // Test 2.1:
    sIn  = 1;
    mode = 2'b11;
    #100;

    // Test 3: mode = 00 (hold)
    mode = 2'b00;
    #100;

    // Test 4: mode = 01 (shift right 1)
    mode = 2'b01;
    #100;

    // Test 5: sIn = 1
    sIn = 1;
    #100;

    // Test 6: sIn = 0
    sIn = 0;
    #100;

    // Test 7: mode = 10 (rotate right)
    mode = 2'b10;
    #100;

    // Test 8: mode = 11 (serial shift 2)
    mode = 2'b11;
    #100;

    // Test 9: inz
    inz  = 1;
    mode = 2'b00;
    #100;
    inz = 0;
    #200;

    $display("Finished simple tests.");
    $stop;
  end

endmodule
