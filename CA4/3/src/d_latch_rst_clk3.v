`timescale 1ns / 1ns

module d_latch_rst_clk3 (
    input wire clk,
    input wire D,
    input wire rst,
    input wire inz,

    output wire Q,
    output wire Q_bar
);
  wire h0, h1, h2;

  and #(8) u0 (h0, ~inz, D);

  nand #(8) u1 (h1, clk, h0);

  nand #(8) u2 (h2, clk, h1);

  nand #(8) u3 (Q, Q_bar, h1);

  nand #(12) u4 (Q_bar, Q, h2, rst);
endmodule
