`timescale 1ns / 1ns

module moore_vs_mealy_tb;

  logic clk, reset_n, serIn;
  logic det_moore, det_mealy;

  /* Post-synthesis Moore */
  moore_10110_post moore (
      .clk(clk),
      .reset_n(reset_n),
      .serIn(serIn),
      .detOut(det_moore)
  );

  /* Post-synthesis Mealy */
  mealy_10110_post mealy (
      .clk(clk),
      .reset_n(reset_n),
      .serIn(serIn),
      .detOut(det_mealy)
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
