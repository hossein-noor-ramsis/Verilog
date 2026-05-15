module ImmediateExt (
    input [31:7] instruction,
    input [ 2:0] imm_src,

    output reg [31:0] imm_extended
);
  always @(instruction, imm_src) begin
    case (imm_src)
      // I-type
      3'b000: imm_extended = {{20{instruction[31]}}, instruction[31:20]};

      // S-type
      3'b001: imm_extended = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};

      // B-type
      3'b011:
      imm_extended = {
        {20{instruction[31]}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0
      };

      // J-type
      3'b010:
      imm_extended = {
        {11{instruction[31]}},
        instruction[31],
        instruction[19:12],
        instruction[20],
        instruction[30:21],
        1'b0
      };

      default: imm_extended = 32'd0;
    endcase
  end
endmodule
