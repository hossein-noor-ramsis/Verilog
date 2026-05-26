module ImmediateExtend (
    input [31:7] instruction,
    input [ 1:0] imm_src,

    output reg [31:0] imm_extended
);
  always @(*) begin
    case (imm_src)
      // I-type
      2'b00: imm_extended = {{20{instruction[31]}}, instruction[31:20]};

      // S-type
      2'b01: imm_extended = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};

      // B-type
      2'b10:
      imm_extended = {
        {20{instruction[31]}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0
      };

      // J-type
      2'b11:
      imm_extended = {
        {12{instruction[31]}}, instruction[19:12], instruction[20], instruction[30:21], 1'b0
      };

      default: imm_extended = 32'd0;
    endcase
  end
endmodule
