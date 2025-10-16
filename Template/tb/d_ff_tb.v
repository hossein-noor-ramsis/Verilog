`timescale 1ns / 1ns  // optional but recommended for simulation

module d_ff_tb;
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
    #21 $finish;
  end

  // Monitor outputs
  initial begin
    $display("Time   clk   rstn   d   q");
    $monitor("%0t    %b    t%b    %b  %b", $time, clk, rstn, d, q);
  end

endmodule
