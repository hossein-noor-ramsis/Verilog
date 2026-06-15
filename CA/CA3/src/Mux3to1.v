module Mux3to1 (
    input  [ 1:0] select,
    input  [31:0] a,
    b,
    c,
    output [31:0] out
);
  assign out = (select == 2'b00) ? a : (select == 2'b01) ? b : (select == 2'b10) ? c : {32{1'b0}};

  // //  Separate sensitivity lists for inputs and outputs
  // always @(select or a or b or c) begin
  //   $display("[%0t] Mux3to1 Input Change: select=%0b, a=0x%0h (%0d), b=0x%0h (%0d), c=0x%0h (%0d)",
  //            $time, select, a, a, b, b, c, c);
  // end

  // always @(out) begin
  //   $display("[%0t] Mux3to1 Output Change: out=0x%0h (%0d)", $time, out, out);
  // end
endmodule
