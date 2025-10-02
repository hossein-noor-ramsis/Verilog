module simple_alu (
    input wire [3:0] a,
    input wire [3:0] b,
    input wire [2:0] op, // operation select

    output reg [3:0] result
);

  always @(*) begin
    case (op)
      3'b000: result = a + b;  // جمع
      3'b001: result = a - b;  // تفریق
      3'b010: result = a & b;  // AND
      3'b011: result = a | b;  // OR
      3'b100: result = a ^ b;  // XOR

      default: result = 0;
    endcase
  end

endmodule
