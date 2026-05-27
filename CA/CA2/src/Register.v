module Register (
    input             clk,
    input             rst,
    input             we,
    input      [31:0] d,
    output reg [31:0] q
);
  always @(posedge clk) begin
    if (rst) q <= 32'd0;
    else if (we) q <= d;
  end
endmodule
