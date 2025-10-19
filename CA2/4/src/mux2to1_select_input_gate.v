`timescale 1ns / 1ns

module mux2to1_select_input_gate (
    input wire a,
    input wire b,
    input wire s,
    input wire e,

    output wire y
);
  wire h1;
  wire h2;
  wire h3;
  wire h4;

  wire not_s;
  not (not_s, s);

  // b nand s
  nand2_gate nand1 (
      b,
      s,
      h1
  );

  // s' nand a
  nand2_gate nand2 (
      not_s,
      a,
      h2
  );

  // h1 nand h2
  nand2_gate nand3 (
      h2,
      h1,
      h3
  );

  // e nand h3
  nand2_gate nand4 (
      e,
      h3,
      h4
  );

  not (y, h4);
endmodule
