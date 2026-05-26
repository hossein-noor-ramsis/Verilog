module Register (
    input clk,
    input [31:0] next_state,

    output reg [31:0] present_state
);
  always @(posedge clk) begin
    present_state <= next_state;
  end
endmodule
