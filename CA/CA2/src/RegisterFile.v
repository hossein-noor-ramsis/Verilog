module RegisterFile (
    input         clk,
    input         we,          // write enable
    input  [ 4:0] rs1,         // read address 1
    input  [ 4:0] rs2,         // read address 2
    input  [ 4:0] rd,          // write address
    input  [31:0] write_data,
    output [31:0] rd1,         // read data 1
    output [31:0] rd2          // read data 2
);
  reg [31:0] regs[0:31];

  // Read (combinational)
  assign rd1 = (rs1 == 5'd0) ? 32'd0 : regs[rs1];
  assign rd2 = (rs2 == 5'd0) ? 32'd0 : regs[rs2];

  // Write (sequential)
  always @(posedge clk) begin
    if (we && (rd != 5'd0)) regs[rd] <= write_data;
  end
endmodule
