module comp_gate (
    input  wire a,
    input  wire b,
    
    input  wire inEq,
    input  wire inGt,

    output wire outEq,
    output wire outGt
);
  wire axb;
  wire n_axb;
  wire nb;
  wire anb;
  wire anb_eq;

  xor (axb, a, b);

  not (n_axb, axb);
  not (nb, b);

  and (anb, a, nb);
  and (anb_eq, anb, inEq);

  and (outEq, inEq, n_axb);
  or (outGt, inGt, anb_eq);
endmodule
