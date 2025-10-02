`timescale 1ns / 1ps  // optional but recommended for simulation

module tb_d_ff;
  wire q;  // output

  // Testbench signals
  reg  clk = 0;  // clock
  reg  rstn = 0;  // active-low reset
  reg  d = 0;  // data input

  // Instantiate the DUT (Device Under Test)
  d_ff dut (
      .clk(clk),
      .rstn(rstn),
      .d(d),
      .q(q)
  );

  // Clock generation: 10ns period
  always #5 clk = ~clk;

  // Stimulus
  initial begin
    // Initialize signals
    rstn = 0;
    d = 0;

    // Apply reset
    #10 rstn = 1;  // release reset after 10 ns

    // Test data input
    #10 d = 1;
    #10 d = 0;
    #10 d = 1;
    #15 d = 0;  // extra time to see changes across clock edges

    // End simulation
    #20 $finish;
  end

  // Monitor outputs
  initial begin
    $display("Time\tclk\trstn\td\tq");
    $monitor("%0t\t%b\t%b\t%b\t%b", $time, clk, rstn, d, q);
  end

endmodule
