module RegisterWe (
    input clk,
    input we,
    input [31:0] next_state,

    output reg [31:0] present_state
);
  always @(posedge clk) begin
    if (we) begin
      present_state <= next_state;
    end
  end
endmodule
