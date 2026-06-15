module RegisterFile (
    input clk,
    we,
    input [4:0] A1,
    A2,
    A3,
    input [31:0] WD3,
    output [31:0] RD1,
    RD2
);
  reg [31:0] regs[0:31];
  initial begin
    regs[0] = 32'b0;
  end

  assign RD1 = regs[A1];
  assign RD2 = regs[A2];
  
  always @(negedge clk) begin
    if (we == 1 && A3 != 32'b0) regs[A3] <= WD3;
    else regs[A3] <= regs[A3];
  end

  // //  Separate sensitivity lists for inputs and outputs
  // Log read address and write enable changes
  // always @(A1 or A2 or A3 or we or WD3) begin
  //   $display("[%0t] RegisterFile Input Change: A1=%0d, A2=%0d, A3=%0d, we=%0b, WD3=0x%0h (%0d)",
  //            $time, A1, A2, A3, we, WD3, WD3);
  // end

  // //  Log read data output changes
  // always @(RD1) begin
  //   $display("[%0t] RegisterFile Read Port 1: A1=%0d, RD1=0x%0h (%0d)", $time, A1, RD1, RD1);
  // end

  // always @(RD2) begin
  //   $display("[%0t] RegisterFile Read Port 2: A2=%0d, RD2=0x%0h (%0d)", $time, A2, RD2, RD2);
  // end

  // // Log write operations on negative clock edge
  // always @(negedge clk) begin
  //   if (we == 1 && A3 != 32'b0)
  //     $display("[%0t] RegisterFile Write: A3=%0d, WD3=0x%0h (%0d)", $time, A3, WD3, WD3);
  // end
endmodule
