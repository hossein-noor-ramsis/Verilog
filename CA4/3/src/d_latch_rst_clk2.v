`timescale 1ns / 1ns

module nand2 (
    output wire Y,

    input wire A,
    input wire B
);
  supply1 VDD;
  supply0 GND;

  wire n1, n2;

  nmos #(4) nA (n1, GND, A);
  nmos #(4) nB (Y, n1, B);

  pmos #(6) pA (Y, VDD, A);
  pmos #(6) pB (Y, VDD, B);
endmodule

module nand3 (
    output wire Y,

    input wire A,
    input wire B,
    input wire C
);

  supply1 VDD;
  supply0 GND;

  wire n1, n2;

  nmos #(4) nA (n1, GND, A);
  nmos #(4) nB (n2, n1, B);
  nmos #(4) nC (Y, n2, C);

  pmos #(6) pA (Y, VDD, A);
  pmos #(6) pB (Y, VDD, B);
  pmos #(6) pC (Y, VDD, C);

endmodule

module d_latch_rst_clk2 (
    input wire clk,
    input wire D,
    input wire rst,

    output wire Q,
    output wire Q_bar
);
  wire h1, h2;

  nand2 u1 (
      h1,
      clk,
      D
  );

  nand2 u2 (
      h2,
      clk,
      h1
  );

  nand2 u3 (
      Q,
      Q_bar,
      h1
  );

  nand3 u4 (
      Q_bar,
      Q,
      h1,
      rst
  );
endmodule
