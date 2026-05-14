`timescale 1ns / 1ns

module mux2to1_select_input_tristate_gate (
    input wire a,
    input wire b,
    input wire s,
    input wire oe,

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

  // if oe == 1: h1 nand h2; else: z
  nand2_tristate_gate nand_tristate (
      h2,
      h1,
      oe,
      y
  );
endmodule
