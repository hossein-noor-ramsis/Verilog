module Register (
    clk,
    en,
    sclr,
    in,
    out
);
  parameter N = 32;
  input clk, en, sclr;
  input [N-1:0] in;
  output reg [N-1:0] out = {N{1'b0}};
  
  always @(posedge clk) begin
    if (sclr) out <= {N{1'b0}};
    else if (en) out <= in;
  end

  // // Separate sensitivity lists for inputs and outputs
  // Log input changes
  // always @(en or sclr or in) begin
  //   $display("[%0t] Register Input Change: en=%0b, sclr=%0b, in=0x%0h (%0d)", $time, en, sclr, in,
  //            in);
  // end

  // Log output changes
  // always @(out) begin
  //   $display("[%0t] Register Output Change: out=0x%0h (%0d)", $time, out, out);
  // end

  // //  Log clock edge operations
  // always @(posedge clk) begin
  //   if (sclr) $display("[%0t] Register Clock Edge: sclr asserted, out cleared to 0", $time);
  //   else if (en)
  //     $display("[%0t] Register Clock Edge: en=%0b, capturing in=0x%0h (%0d)", $time, en, in, in);
  //   else
  //     $display("[%0t] Register Clock Edge: en=%0b, holding out=0x%0h (%0d)", $time, en, out, out);
  // end
endmodule
