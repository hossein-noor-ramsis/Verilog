`timescale 1ns / 1ns

module nand2_gate (
    input wire a,
    input wire b,

    output wire w
);
  supply1 vdd;
  supply0 gnd;

  wire h1;

  nmos #(3, 4, 5) (h1, gnd, b);
  nmos #(3, 4, 5) (w, h1, a);

  pmos #(5, 6, 7) (w, vdd, a);
  pmos #(5, 6, 7) (w, vdd, b);

endmodule
