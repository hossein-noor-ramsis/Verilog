`timescale 1ns / 1ns

module dff (
    input  wire clk,
    input  wire rst,
    input  wire inz,
    input  wire D,
    output wire Q,
    output wire Q_bar
);
  wire master_Q, master_Qbar;
  wire slave_Q, slave_Qbar;
  wire clk_bar; 

  not #(4) (clk_bar, clk);

  d_latch_rst_clk3 master (
      .clk  (clk),        
      .D    (D),
      .rst  (rst),
      .inz  (inz),
      .Q    (master_Q),
      .Q_bar(master_Qbar)
  );

  d_latch_rst_clk3 slave (
      .clk  (clk_bar),  
      .D    (master_Q),
      .rst  (rst),
      .inz  (1'b0),
      .Q    (slave_Q),
      .Q_bar(slave_Qbar)
  );

  assign Q     = slave_Q;
  assign Q_bar = slave_Qbar;

endmodule
