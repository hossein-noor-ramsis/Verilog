module d_ff (
    input  wire clk,
    input  wire rstn,
    input  wire d,
    output reg  q
);
  always @(posedge clk or negedge rstn) begin
    if (!rstn) q <= 0;  // reset
    else q <= d;  // store input
  end
endmodule
