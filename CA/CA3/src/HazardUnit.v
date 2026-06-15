module HazardUnit (
    input RegWriteM,
    RegWriteW,

    input [1:0] ResultSrcE,
    PCSrcE,
    ResultSrcM,
    ResultSrcW,

    input [4:0] Rs1D,
    Rs2D,
    Rs1E,
    Rs2E,
    RdE,
    RdM,
    RdW,

    output StallF,
    StallD,
    FlushD,
    FlushE,

    output [1:0] ForwardAE,
    ForwardBE
);
  wire lwStall;
  
  assign ForwardAE=((Rs1E==RdM && RegWriteM)&&Rs1E!=0)?2'b10:
			 (((Rs1E==RdW && RegWriteW)&&Rs1E!=0) || (Rs1E==RdW && ResultSrcW==2'b11 && Rs1E!=0))?2'b01:
			(Rs1E==RdM && ResultSrcM==2'b11 && Rs1E!=0)?2'b11:
			 2'b00;

  assign ForwardBE=((Rs2E==RdM && RegWriteM)&&Rs2E!=0)?2'b10:
			(((Rs2E==RdW && RegWriteW)&&Rs2E!=0) || (Rs2E==RdW && ResultSrcW==2'b11 && Rs2E!=0))?2'b01:
			 (Rs2E==RdM && ResultSrcM==2'b11 && Rs2E!=0)?2'b11:
			 2'b00;

  assign lwStall = ((Rs1D == RdE) || (Rs2D == RdE)) && ResultSrcE == 2'b01;
  assign StallF = lwStall;
  assign StallD = lwStall;
  assign FlushE = lwStall || (PCSrcE == 2'b01) || (PCSrcE == 2'b10);
  assign FlushD = (PCSrcE == 2'b01) ? 1 : 0;

  // //  Separate sensitivity lists for inputs and outputs
  // always @(RegWriteM or RegWriteW or ResultSrcE or PCSrcE or ResultSrcM or ResultSrcW or Rs1D or Rs2D or Rs1E or Rs2E or RdE or RdM or RdW) begin
  //   $display(
  //       "[%0t] HazardUnit Input Change: RegWriteM=%0b, RegWriteW=%0b, ResultSrcE=%0b, PCSrcE=%0b, ResultSrcM=%0b, ResultSrcW=%0b",
  //       $time, RegWriteM, RegWriteW, ResultSrcE, PCSrcE, ResultSrcM, ResultSrcW);
  //   $display(
  //       "[%0t] HazardUnit Registers: Rs1D=%0d, Rs2D=%0d, Rs1E=%0d, Rs2E=%0d, RdE=%0d, RdM=%0d, RdW=%0d",
  //       $time, Rs1D, Rs2D, Rs1E, Rs2E, RdE, RdM, RdW);
  // end

  // always @(StallF or StallD or FlushD or FlushE or ForwardAE or ForwardBE) begin
  //   $display(
  //       "[%0t] HazardUnit Output Change: StallF=%0b, StallD=%0b, FlushD=%0b, FlushE=%0b, ForwardAE=%0b, ForwardBE=%0b, lwStall=%0b",
  //       $time, StallF, StallD, FlushD, FlushE, ForwardAE, ForwardBE, lwStall);
  // end
endmodule
