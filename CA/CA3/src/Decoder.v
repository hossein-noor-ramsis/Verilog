module Decoder (
    input JalrE,
    JumpE,
    BranchE,
    ZeroE,
    sign,
    input [2:0] func3,
    output [1:0] PCSrc
);
  assign PCSrc = (JalrE) ? 2'b10 : ((JumpE) || (BranchE && func3 == 3'b000 && ZeroE) ||  // beq
      (BranchE && func3 == 3'b001 && ~ZeroE) ||  // bne
      (BranchE && func3 == 3'b100 && sign) ||  //blt
      (BranchE && func3 == 3'b101 && ~sign)) ? 2'b01 :  //bge
      2'b00;

  // //  Separate sensitivity lists for inputs and outputs
  // always @(JalrE or JumpE or BranchE or ZeroE or neg or func3) begin
  //   $display(
  //       "[%0t] Decoder Input Change: JalrE=%0b, JumpE=%0b, BranchE=%0b, ZeroE=%0b, neg=%0b, func3=%0b",
  //       $time, JalrE, JumpE, BranchE, ZeroE, neg, func3);
  // end

  // always @(PCSrc) begin
  //   $display("[%0t] Decoder Output Change: PCSrc=%0b", $time, PCSrc);
  // end
endmodule
