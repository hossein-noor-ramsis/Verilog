module moore_10110_tb;

  logic clk;
  logic reset_n;
  logic serIn;
  logic detOut;

  /* DUT */
  moore_10110 dut (
      .clk(clk),
      .reset_n(reset_n),
      .serIn(serIn),
      .detOut(detOut)
  );

  /* Clock */
  always #5 clk = ~clk;

  /* Test */
  initial begin
    clk = 0;
    reset_n = 0;
    serIn = 0;

    #10 reset_n = 1;

    // Input sequence: 10110
    #10 serIn = 1;
    #10 serIn = 0;
    #10 serIn = 1;
    #10 serIn = 1;
    #10 serIn = 0;

    #40 $stop;
  end

endmodule
