module PC (
    input clk,
    rst,

    input [31:0] pc_next,

    output reg [31:0] pc_current
);
  always @(posedge clk) begin
    if (rst) pc_current <= 32'd0;
    else pc_current <= pc_next;
  end
endmodule
