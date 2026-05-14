`timescale 1ns / 1ns

module msrr8 (
    input  logic       clk,
    input  logic       rst,
    input  logic [1:0] mode,  // 00: hold, 01: shift1, 10: rotate1, 11: serial2
    input  logic       sIn,
    input  logic       inz,
    input  logic [7:0] PI,
    output logic [7:0] Q
);

  logic [7:0] Q_bar;
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

  d_latch_rst_clk3 l0 (
      .clk(clk),
      .D(D[0]),
      .rst(rst),
      .inz(inz),
      .Q(Q[0]),
      .Q_bar(Q_bar[0])
  );

  d_latch_rst_clk3 l1 (
      .clk(clk),
      .D(D[1]),
      .rst(rst),
      .inz(inz),
      .Q(Q[1]),
      .Q_bar(Q_bar[1])
  );

  d_latch_rst_clk3 l2 (
      .clk(clk),
      .D(D[2]),
      .rst(rst),
      .inz(inz),
      .Q(Q[2]),
      .Q_bar(Q_bar[2])
  );

  d_latch_rst_clk3 l3 (
      .clk(clk),
      .D(D[3]),
      .rst(rst),
      .inz(inz),
      .Q(Q[3]),
      .Q_bar(Q_bar[3])
  );

  d_latch_rst_clk3 l4 (
      .clk(clk),
      .D(D[4]),
      .rst(rst),
      .inz(inz),
      .Q(Q[4]),
      .Q_bar(Q_bar[4])
  );

  d_latch_rst_clk3 l5 (
      .clk(clk),
      .D(D[5]),
      .rst(rst),
      .inz(inz),
      .Q(Q[5]),
      .Q_bar(Q_bar[5])
  );

  d_latch_rst_clk3 l6 (
      .clk(clk),
      .D(D[6]),
      .rst(rst),
      .inz(inz),
      .Q(Q[6]),
      .Q_bar(Q_bar[6])
  );

  d_latch_rst_clk3 l7 (
      .clk(clk),
      .D(D[7]),
      .rst(rst),
      .inz(inz),
      .Q(Q[7]),
      .Q_bar(Q_bar[7])
  );

endmodule
