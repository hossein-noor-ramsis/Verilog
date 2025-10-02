// File: alu_16bit.sv
module alu_16bit (
    input  logic [15:0] a,      // operand A
    input  logic [15:0] b,      // operand B
    input  logic [ 2:0] op,     // operation selector
    output logic [15:0] result  // result
);

  always_comb begin
    case (op)
      3'b000:  result = a + b;  // ADD
      3'b001:  result = a - b;  // SUB
      3'b010:  result = a & b;  // AND
      3'b011:  result = a | b;  // OR
      3'b100:  result = a ^ b;  // XOR
      default: result = 16'b0;  // default
    endcase
  end
endmodule


// iverilog -g2012 -o alu_test tb_alu_16bit.sv alu_16bit.sv
// vvp alu_test

