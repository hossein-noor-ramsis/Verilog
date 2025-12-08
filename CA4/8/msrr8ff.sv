`timescale 1ns / 1ns

module msrr8ff (
    input  logic       clk,
    input  logic       rst,
    input  logic       inz,
    input  logic [1:0] mode,
    input  logic       sIn,
    output logic [7:0] Q
);
  logic [7:0] D;

  always @(mode, sIn, D, clk) begin
    case (mode)
      2'b00:   D = Q;
      2'b01:   D = {1'b0, Q[7:1]};
      2'b10:   D = {Q[0], Q[7:1]};
      2'b11:   D = {sIn, sIn, Q[7:2]};
      default: D = Q;
    endcase
  end

  genvar i;
  generate
    for (i = 0; i < 8; i = i + 1) begin : ff_loop
      dff ff (
          .clk(clk),
          .rst(rst),
          .inz(inz),
          .D(D[i]),
          .Q(Q[i]),
          .Q_bar()
      );
    end
  endgenerate
endmodule
