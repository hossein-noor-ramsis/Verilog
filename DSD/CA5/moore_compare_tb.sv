`timescale 1ns / 1ns

module moore_compare_tb;
  logic clk, reset_n, serIn;
  logic det_pre, det_post;

  /* Pre-synthesis */
  moore_10110 pre (
      .clk(clk),
      .reset_n(reset_n),
      .serIn(serIn),
      .detOut(det_pre)
  );

  /* Post-synthesis */
  moore_10110_post post (
      .clk(clk),
      .reset_n(reset_n),
      .serIn(serIn),
      .detOut(det_post)
  );

  always #5 clk = ~clk;

  initial begin
    clk = 0;
    reset_n = 0;
    serIn = 0;

    #10 reset_n = 1;

    #10 serIn = 1;
    #10 serIn = 0;
    #10 serIn = 1;
    #10 serIn = 1;
    #10 serIn = 0;

    #50 $stop;
  end

endmodule
