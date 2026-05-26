module ALU (
    input signed [31:0] operand_a,
    input signed [31:0] operand_b,
    input [2:0] alu_control,

    output zero_flag,
    output sign_flag,
    output reg signed [31:0] alu_result
);
  assign zero_flag = (alu_result == 32'd0);
  assign sign_flag = alu_result[31];

  always @(*) begin
    case (alu_control)
      3'b000: alu_result = operand_a + operand_b;

      3'b001: alu_result = operand_a - operand_b;

      3'b010: alu_result = operand_a & operand_b;

      3'b011: alu_result = operand_a | operand_b;

      3'b100: alu_result = operand_a ^ operand_b;

      3'b101:  alu_result = (operand_a < operand_b) ? 32'd1 : 32'd0;  // SLT
      default: alu_result = 32'd0;
    endcase
  end
endmodule
