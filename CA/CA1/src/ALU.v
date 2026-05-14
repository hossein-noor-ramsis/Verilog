module ALU (
    input signed [31:0] operand_a,
    operand_b,

    input  [2:0] alu_control,
    output       zero_flag,
    sign_flag,

    output reg signed [31:0] alu_result
);
  assign zero_flag = ~|alu_result;
  assign sign_flag = alu_result[31];

  always @(operand_a, operand_b, alu_control) begin
    case (alu_control)
      3'b000:  alu_result = operand_a & operand_b;  // AND
      3'b001:  alu_result = operand_a | operand_b;  // OR
      3'b010:  alu_result = operand_a + operand_b;  // ADD
      3'b110:  alu_result = operand_a - operand_b;  // SUB
      3'b011:  alu_result = operand_a ^ operand_b;  // XOR
      3'b111:  alu_result = (operand_a < operand_b) ? 1 : 0;  // SLT
      default: alu_result = 0;
    endcase
  end
endmodule
