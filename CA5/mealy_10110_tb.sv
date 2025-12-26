module tb_mealy_10110;

  logic clk, reset_n, serIn;
  logic detOut;

  mealy_10110 dut (
      .clk(clk),
      .reset_n(reset_n),
      .serIn(serIn),
      .detOut(detOut)
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
    #10 serIn = 0;  // detOut goes high IMMEDIATELY

    #40 $stop;
  end

endmodule
