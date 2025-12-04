`timescale 1ns / 1ns

module d_latch_rst_clk_tb;
  logic clk;
  logic D;
  logic rst;

  logic Q;
  logic Q_bar;

  // Instantiate the DUT (Device Under Test)
  d_latch_rst_clk dut (
      .clk(clk),
      .D  (D),
      .rst(rst),

      .Q(Q),
      .Q_bar(Q_bar)
  );

  initial begin
    rst = 0;
    clk = 1;
    D   = 1;
    #50;

    D = 0;
    #50;

    D = 1;
    #50;
    $finish;
  end

  // Monitor changes (print internal wires)
  initial begin
    $monitor("t=%0t | clk=%b | D=%b | rst=%b | Q=%b | Q_bar=%b", $time, clk, D, rst, dut.Q,
             dut.Q_bar);
  end

endmodule
