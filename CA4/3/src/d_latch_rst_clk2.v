`timescale 1ns / 1ns

module d_latch_rst_clk2 (
    input wire clk,
    input wire D,
    input wire rst,

    output wire Q,
    output wire Q_bar
);
  wire h1, h2;

  nand #(8) u1 (h1, clk, D);

  nand #(8) u2 (h2, clk, h1);

  nand #(8) u3 (Q, Q_bar, h1);

  nand #(12) u4 (Q_bar, Q, h2, rst);
endmodule
