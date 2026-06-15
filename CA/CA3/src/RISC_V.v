module RISC_V (
    input clk
);
  wire		MemWriteD,ALUSrcD,RegWriteD,JumpD,BranchD,JalrD,RegWriteM,RegWriteW,JalrE,JumpE,BranchE,ZeroE,ALUResultSign,StallF,StallD,FlushD,FlushE;
  wire [1:0] ResultSrcD, ResultSrcE, PCSrcE, ForwardAE, ForwardBE, ResultSrcM, ResultSrcW;
  wire [2:0] func3D, func3E, ALUControlD, ImmSrcD;
  wire [4:0] Rs1D, Rs2D, Rs1E, Rs2E, RdE, RdM, RdW;
  wire [6:0] func7, op;

  Controller CTRL (
      func3D,
      func7,
      op,
      MemWriteD,
      ALUSrcD,
      RegWriteD,
      JumpD,
      BranchD,
      JalrD,
      ResultSrcD,
      ALUControlD,
      ImmSrcD
  );
  
  HazardUnit HU (
      RegWriteM,
      RegWriteW,
      ResultSrcE,
      PCSrcE,
      ResultSrcM,
      ResultSrcW,
      Rs1D,
      Rs2D,
      Rs1E,
      Rs2E,
      RdE,
      RdM,
      RdW,
      StallF,
      StallD,
      FlushD,
      FlushE,
      ForwardAE,
      ForwardBE
  );

  Decoder DC (
      JalrE,
      JumpE,
      BranchE,
      ZeroE,
      ALUResultSign,
      func3E,
      PCSrcE
  );

  DataPath DP (
      clk,
      MemWriteD,
      ALUSrcD,
      RegWriteD,
      JumpD,
      BranchD,
      JalrD,
      StallF,
      StallD,
      FlushD,
      FlushE,
      ResultSrcD,
      ForwardAE,
      ForwardBE,
      PCSrcE,
      ALUControlD,
      ImmSrcD,
      BranchE,
      JumpE,
      JalrE,
      ZeroE,
      ALUResultSign,
      RegWriteM,
      RegWriteW,
      ResultSrcE,
      func3D,
      func3E,
      func7,
      op,
      Rs1D,
      Rs2D,
      Rs1E,
      Rs2E,
      RdE,
      RdM,
      RdW,
      ResultSrcM,
      ResultSrcW
  );

  // // Separate sensitivity lists for key top-level signals
  // // Control signals from Controller to DataPath
  // always @(MemWriteD or ALUSrcD or RegWriteD or JumpD or BranchD or JalrD or ResultSrcD or ALUControlD or ImmSrcD) begin
  //   $display(
  //       "[%0t] RISC_V Control Signals: MemWriteD=%0b, ALUSrcD=%0b, RegWriteD=%0b, JumpD=%0b, BranchD=%0b, JalrD=%0b, ResultSrcD=%0b, ALUControlD=%0b, ImmSrcD=%0b",
  //       $time, MemWriteD, ALUSrcD, RegWriteD, JumpD, BranchD, JalrD, ResultSrcD, ALUControlD,
  //       ImmSrcD);
  // end

  // // Hazard Unit outputs
  // always @(StallF or StallD or FlushD or FlushE or ForwardAE or ForwardBE) begin
  //   $display(
  //       "[%0t] RISC_V Hazard Signals: StallF=%0b, StallD=%0b, FlushD=%0b, FlushE=%0b, ForwardAE=%0b, ForwardBE=%0b",
  //       $time, StallF, StallD, FlushD, FlushE, ForwardAE, ForwardBE);
  // end

  // // Decoder output (PCSrcE)
  // always @(PCSrcE) begin
  //   $display("[%0t] RISC_V PC Source: PCSrcE=%0b", $time, PCSrcE);
  // end

  // // DataPath execution signals
  // always @(BranchE or JumpE or JalrE or ZeroE or ALUResultSign) begin
  //   $display(
  //       "[%0t] RISC_V Execution Signals: BranchE=%0b, JumpE=%0b, JalrE=%0b, ZeroE=%0b, ALUResultSign=%0b",
  //       $time, BranchE, JumpE, JalrE, ZeroE, ALUResultSign);
  // end

  // // Writeback signals
  // always @(RegWriteM or RegWriteW or ResultSrcM or ResultSrcW) begin
  //   $display(
  //       "[%0t] RISC_V Writeback Signals: RegWriteM=%0b, RegWriteW=%0b, ResultSrcM=%0b, ResultSrcW=%0b",
  //       $time, RegWriteM, RegWriteW, ResultSrcM, ResultSrcW);
  // end

  // // Instruction decode fields
  // always @(func3D or func3E or func7 or op or Rs1D or Rs2D or Rs1E or Rs2E or RdE or RdM or RdW) begin
  //   $display(
  //       "[%0t] RISC_V Instruction Fields: op=%0b, func3D=%0b, func3E=%0b, func7=%0b, Rs1D=%0d, Rs2D=%0d, Rs1E=%0d, Rs2E=%0d, RdE=%0d, RdM=%0d, RdW=%0d",
  //       $time, op, func3D, func3E, func7, Rs1D, Rs2D, Rs1E, Rs2E, RdE, RdM, RdW);
  // end

  // // Clock edge summary
  // always @(posedge clk) begin
  //   $display("=== RISC_V Clock Cycle at time %0t ===", $time);
  // end
endmodule
