module RegisterWithEnable (
    input             clk,
    input             we,   // write enable
    input      [31:0] d,
    output reg [31:0] q
);
  always @(posedge clk) begin
    if (we) q <= d;
  end
endmodule
