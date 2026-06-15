module Adder (
    input [31:0] in1,
    in2,

    output [31:0] out
);
  assign out = in1 + in2;

  // //  Separate sensitivity lists for inputs and output
  // always @(in1 or in2) begin
  //   $display("[%0t] Adder Input Change: in1=%0d (0x%0h), in2=%0d (0x%0h)", $time, in1, in1, in2,
  //            in2);
  // end

  // always @(out) begin
  //   $display("[%0t] Adder Output Change: out=%0d (0x%0h)", $time, out, out);
  // end
endmodule
