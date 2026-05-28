module Register #(
    parameter ID = "UNKNOWN"
) (
    input             clk,
    input             rst,
    input             we,
    input      [31:0] d,
    output reg [31:0] q
);
  always @(posedge clk) begin
    if (rst) begin
      q <= 32'd0;
      if (we) $display("Reg %s: rst=%b, we=%b, d=%0d (0x%08h)", ID, rst, we, $signed(d), d);
    end else if (we) begin
      q <= d;
      $display("Reg %s WRITE: d=%0d (0x%08h)", ID, $signed(d), d);
    end
  end
endmodule
