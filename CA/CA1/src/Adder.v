module Adder (
    input signed [31:0] operand_a,
    operand_b,

    output signed [31:0] adder_result
);
  assign adder_result = operand_a + operand_b;
endmodule
