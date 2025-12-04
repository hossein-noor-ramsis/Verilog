`timescale 1ns / 1ns

module d_latch_rst_clk_tb2;
  reg clk, D, rst;
  wire Q, Q_bar;

  d_latch_rst_clk2 uut (
      .clk(clk),
      .D  (D),
      .rst(rst),

      .Q(Q),
      .Q_bar(Q_bar)
  );

  initial begin
    clk = 1;
    forever #200 clk = ~clk;
  end

  initial begin
    rst = 1'b1;
    #200;

    rst = 1'b0;
    D   = 0;
    #400;

    rst = 1'b1;
    #400;

    D = 0;
    #400;

    D = 1;
    #400;

    D = 0;
    #400;

    D = 1;
    #400;

    rst = 0;
    #400;
    $stop;
  end

endmodule
