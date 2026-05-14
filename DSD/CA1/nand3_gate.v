`timescale 1ns / 1ns

module nand3_gate (
    input wire a,
    input wire b,
    input wire c,

    output wire w
);
  supply1 vdd;
  supply0 gnd;

  wire h1;
  wire h2;

  nmos #(3, 4, 5) (h1, gnd, b);
  nmos #(3, 4, 5) (h2, h1, c);
  nmos #(3, 4, 5) (w, h2, a);

  pmos #(5, 6, 7) (w, vdd, a);
  pmos #(5, 6, 7) (w, vdd, b);
  pmos #(5, 6, 7) (w, vdd, c);

endmodule
