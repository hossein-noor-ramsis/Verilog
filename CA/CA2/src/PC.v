module PC (
    input clk,
    input rst,
    input we,

    input      [31:0] next_pc,
    output reg [31:0] pc
);
  always @(posedge clk) begin
    if (rst) pc <= 32'd0;
    else if (we) pc <= next_pc;
  end
endmodule
