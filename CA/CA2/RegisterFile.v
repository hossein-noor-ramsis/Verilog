module RegisterFile (
    input clk,
    input write_enable,

    input [4:0] rs1_addr,
    input [4:0] rs2_addr,
    input [4:0] rd_addr,

    input [31:0] write_data,

    output [31:0] rs1_data,
    output [31:0] rs2_data
);
  reg [31:0] reg_file[0:31];

  integer i;

  initial begin
    for (i = 0; i < 32; i = i + 1) begin
      reg_file[i] = 32'd0;
    end
  end

  // Read operations (combinational)
  // x0 always reads as 0
  assign rs1_data = (rs1_addr == 5'd0) ? 32'd0 : reg_file[rs1_addr];
  assign rs2_data = (rs2_addr == 5'd0) ? 32'd0 : reg_file[rs2_addr];

  // Write operation (sequential)
  always @(posedge clk) begin
    if (write_enable && (rd_addr != 5'd0)) begin
      reg_file[rd_addr] <= write_data;
    end
  end
endmodule
