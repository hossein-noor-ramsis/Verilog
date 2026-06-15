module ALU (
    input [31:0] SrcA,
    SrcB,

    input [2:0] control,
    output reg [31:0] res,
    output zero
);

  assign zero = ~|res;

  always @(SrcA, SrcB, control) begin
    case (control)
      3'b000:  res = SrcA & SrcB;
      3'b001:  res = SrcA | SrcB;
      3'b010:  res = SrcA + SrcB;
      3'b110:  res = SrcA - SrcB;
      3'b011:  res = SrcA ^ SrcB;
      3'b100:  res = $signed(SrcA) < $signed(SrcB) ? 'd1 : 'd0;  // signed
      default: res = 32'd0;
    endcase
  end

  // //  Separate sensitivity lists for inputs and outputs
  // always @(SrcA or SrcB or control) begin
  //   $display("[%0t] ALU Input Change: SrcA=%0d (0x%0h), SrcB=%0d (0x%0h), control=%0b", $time,
  //            SrcA, SrcA, SrcB, SrcB, control);
  // end

  // always @(res) begin
  //   $display("[%0t] ALU Output Change: res=%0d (0x%0h), zero=%0b, sign=%0b", $time, res, res, zero,
  //            sign);
  // end
endmodule
