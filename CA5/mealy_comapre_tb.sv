`timescale 1ns / 1ns

module mealy_pre_post_tb;

  logic clk;
  logic reset_n;
  logic serIn;

  logic det_pre;  // pre-synthesis output
  logic det_post;  // post-synthesis output

  mealy_10110 u_pre (
      .clk(clk),
      .reset_n(reset_n),
      .serIn(serIn),
      .detOut(det_pre)
  );

  mealy_10110_post u_post (
      .clk(clk),
      .reset_n(reset_n),
      .serIn(serIn),
      .detOut(det_post)
  );

  /* Clock generator */
  always #5 clk = ~clk;

  /* Stimulus */
  initial begin
    clk = 0;
    reset_n = 0;
    serIn = 0;

    #12 reset_n = 1;

    // Apply sequence: 10110
    #10 serIn = 1;
    #10 serIn = 0;
    #10 serIn = 1;
    #10 serIn = 1;
    #10 serIn = 0;

    #50 $stop;
  end

endmodule
