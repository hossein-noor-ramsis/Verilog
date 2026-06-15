module Mux2to1 (
    input select,
    input [31:0] a,
    b,
    output [31:0] out
);
  assign out = (select == 0) ? a : b;

  // //  Separate sensitivity lists for inputs and outputs
  // always @(select or a or b) begin
  //   $display("[%0t] Mux2to1 Input Change: select=%0b, a=0x%0h (%0d), b=0x%0h (%0d)", $time, select,
  //            a, a, b, b);
  // end

  // always @(out) begin
  //   $display("[%0t] Mux2to1 Output Change: out=0x%0h (%0d)", $time, out, out);
  // end
endmodule
