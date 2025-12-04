module d_latch_rst_clk (
    input wire clk,
    input wire D,
    input wire rst,

    output wire Q,
    output wire Q_bar
);
  wire h1, h2;

  nand (h1, clk, D);
  nand (h2, clk, h1);

  nand (Q, Q_bar, h1);
  nand (Q_bar, Q, h1, rst);
endmodule
