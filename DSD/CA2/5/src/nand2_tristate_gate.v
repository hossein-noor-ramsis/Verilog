`timescale 1ns / 1ns

module nand2_tristate_gate (
    input wire a,
    input wire b,
    input wire c,

    output wire w
);
  supply1 vdd;
  supply0 gnd;

  wire h1;
  wire h2;

  // nand
  nmos #(3, 4, 5) (h1, gnd, b);
  nmos #(3, 4, 5) (h2, h1, a);

  pmos #(5, 6, 7) (h2, vdd, a);
  pmos #(5, 6, 7) (h2, vdd, b);

  // ternary
  nmos #(3, 4, 5) (w, h2, c);
  pmos #(5, 6, 7) (w, h2, ~c);
endmodule
