module comp16_component (
    input  wire [15:0] A,
    input  wire [15:0] B,
    output wire        isEq,
    output wire        isGt
);

  wire [16:0] eqChain;
  wire [16:0] gtChain;

  assign eqChain[16] = 1'b1;
  assign gtChain[16] = 1'b0;

  genvar i;
  generate
    for (i = 15; i >= 0; i = i - 1) begin : cmp
      comp_gate u_cmp (
          .a    (A[i]),
          .b    (B[i]),
          .inEq (eqChain[i+1]),
          .inGt (gtChain[i+1]),
          .outEq(eqChain[i]),
          .outGt(gtChain[i])
      );
    end
  endgenerate

  assign isEq = eqChain[0];
  assign isGt = gtChain[0];

endmodule
