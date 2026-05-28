module RegisterFile (
    input         clk,
    input         we,
    input  [ 4:0] rs1,
    input  [ 4:0] rs2,
    input  [ 4:0] rd,
    input  [31:0] write_data,
    output [31:0] rd1,
    output [31:0] rd2
);
  reg [31:0] regs[0:31];

  integer i;
  initial begin
    for (i = 0; i < 32; i = i + 1) begin
      regs[i] = 32'd0;
    end
  end

  assign rd1 = (rs1 == 5'd0) ? 32'd0 : regs[rs1];
  assign rd2 = (rs2 == 5'd0) ? 32'd0 : regs[rs2];

  always @(rs1, rs2, rd, we, write_data) begin
    $display(
        "RegFile: rs1=%0d (x%0d), rs2=%0d (x%0d), rd=%0d (x%0d), we=%b, write_data=%0d (0x%08h), rd1=%0d (0x%08h), rd2=%0d (0x%08h)",
        rs1, rs1, rs2, rs2, rd, rd, we, $signed(write_data), write_data,
        $signed((rs1 == 5'd0) ? 32'd0 : regs[rs1]), (rs1 == 5'd0) ? 32'd0 : regs[rs1],
        $signed((rs2 == 5'd0) ? 32'd0 : regs[rs2]), (rs2 == 5'd0) ? 32'd0 : regs[rs2]);
  end

  always @(posedge clk) begin
    if (we && (rd != 5'd0)) begin
      regs[rd] <= write_data;
      $display("RegFile WRITE: x%0d = %0d (0x%08h)", rd, $signed(write_data), write_data);
    end
  end
endmodule
