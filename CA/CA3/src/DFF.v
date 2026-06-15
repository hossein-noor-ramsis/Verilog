module DFF (
    clk,
    en,
    sclr,
    in,
    out
);
  input clk, en, sclr, in;
  output reg out = 1'b0;
  
  always @(posedge clk)
    if (sclr) out <= 1'b0;
    else if (en) out <= in;

  // //  Separate sensitivity lists for inputs and outputs
  // Log input changes
  // always @(en or sclr or in) begin
  //   $display("[%0t] DFF Input Change: en=%0b, sclr=%0b, in=%0b", $time, en, sclr, in);
  // end

  // // Log output changes
  // always @(out) begin
  //   $display("[%0t] DFF Output Change: out=%0b", $time, out);
  // end

  // // Log clock edge operations
  // always @(posedge clk) begin
  //   if (sclr) $display("[%0t] DFF Clock Edge: sclr asserted, out cleared to 0", $time);
  //   else if (en) $display("[%0t] DFF Clock Edge: en=%0b, capturing in=%0b", $time, en, in);
  //   else $display("[%0t] DFF Clock Edge: en=%0b, holding out=%0b", $time, en, out);
  // end
endmodule
