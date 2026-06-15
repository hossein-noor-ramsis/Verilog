module DataPath (
    input clk,
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

    input [1:0] ResultSrcD,
    ForwardAE,
    ForwardBE,
    PCSrcE,

    input [2:0] ALUControlD,
    ImmSrcD,

    output BranchE,
    JumpE,
    JalrE,
    ZeroE,
    ALUResultSign,
    RegWriteM,
    RegWriteW,

    output [1:0] ResultSrcE,
    output [2:0] func3D,
    func3E,

    output [6:0] func7,
    op,

    output [4:0] Rs1D,
    Rs2D,
    Rs1E,
    Rs2E,
    RdE,
    RdM,
    RdW,

    output [1:0] ResultSrcM,
    ResultSrcW
);

  wire[31:0]	PCPlus4F,PCTargetE,ALUResultE,PCF_,PCF,InstrF,InstrD,ResultW,RD1D,RD2D,ExtImmD,SrcAE,ALUResultM,RD1E,RD2E,
		WriteDataE,ExtImmE,SrcBE,PCE,WriteDataM,ReadDataM,ALUResultW,ReadDataW,PCPlus4W,ExtImmW,PCD,PCPlus4D,PCPlus4E,ExtImmM,
		PCPlus4M;

  wire [4:0] RdD;
  wire [2:0] ALUControlE;

  wire MemWriteM, RegWriteE, MemWriteE, ALUSrcE;

  assign  Rs1D = InstrD[19:15];
  assign  Rs2D = InstrD[24:20];
  assign  RdD =  InstrD[11:7];
  assign  func3D = InstrD[14:12];
  assign func7 = InstrD[31:25];
  assign  op    = InstrD[6:0];

  assign ALUResultSign = ALUResultE[0];

  Mux3to1 PCMux (
      PCSrcE,
      PCPlus4F,
      PCTargetE,
      ALUResultE,
      PCF_
  );

  Register PCReg (
      clk,
      ~StallF,
      1'b0,
      PCF_,
      PCF
  );

  InstMemory IM (
      PCF,
      InstrF
  );

  Adder PCAdd4 (
      PCF,
      4,
      PCPlus4F
  );

  IF_ID_Regs IF_ID_Reg (
      clk,
      FlushD,
      ~StallD,
      InstrF,
      PCF,
      PCPlus4F,
      InstrD,
      PCD,
      PCPlus4D
  );

  RegisterFile RF (
      clk,
      RegWriteW,
      InstrD[19:15],
      InstrD[24:20],
      RdW,
      ResultW,
      RD1D,
      RD2D
  );

  ImmExt Extend (
      ImmSrcD,
      InstrD[31:7],
      ExtImmD
  );

  ID_EX_Regs ID_EX_Reg (
      clk,
      FlushE,
      RegWriteD,
      MemWriteD,
      ALUSrcD,
      JumpD,
      BranchD,
      JalrD,
      ResultSrcD,
      ALUControlD,
      func3D,
      Rs1D,
      Rs2D,
      RdD,
      PCD,
      ExtImmD,
      PCPlus4D,
      RD1D,
      RD2D,
      RegWriteE,
      MemWriteE,
      ALUSrcE,
      JumpE,
      BranchE,
      JalrE,
      ResultSrcE,
      ALUControlE,
      func3E,
      Rs1E,
      Rs2E,
      RdE,
      PCE,
      ExtImmE,
      PCPlus4E,
      RD1E,
      RD2E
  );

  Mux3to1 ForwardAMux (
      ForwardAE,
      RD1E,
      ResultW,
      ALUResultM,
      SrcAE
  );

  Mux3to1 ForwardBMux (
      ForwardBE,
      RD2E,
      ResultW,
      ALUResultM,
      WriteDataE
  );

  Mux2to1 ALUSrcBMux (
      ALUSrcE,
      WriteDataE,
      ExtImmE,
      SrcBE
  );

  Adder PCImmAdd (
      PCE,
      ExtImmE,
      PCTargetE
  );

  ALU ALU (
      SrcAE,
      SrcBE,
      ALUControlE,
      ALUResultE,
      ZeroE
  );

  EX_Mem_Regs EX_Mem_Reg (
      clk,
      RegWriteE,
      MemWriteE,
      ResultSrcE,
      RdE,
      ALUResultE,
      WriteDataE,
      ExtImmE,
      PCPlus4E,
      RegWriteM,
      MemWriteM,
      ResultSrcM,
      RdM,
      ALUResultM,
      WriteDataM,
      ExtImmM,
      PCPlus4M
  );

  DataMem DataMemory (
      clk,
      MemWriteM,
      ALUResultM,
      WriteDataM,
      ReadDataM
  );

  Mem_WB_Regs Mem_WB_Reg (
      clk,
      RegWriteM,
      ResultSrcM,
      RdM,
      ALUResultM,
      ReadDataM,
      ExtImmM,
      PCPlus4M,
      RegWriteW,
      ResultSrcW,
      RdW,
      ALUResultW,
      ReadDataW,
      ExtImmW,
      PCPlus4W
  );

  Mux3to1 ResultSrcMux (
      ResultSrcW,
      ALUResultW,
      ReadDataW,
      PCPlus4W,
      ResultW
  );

  // // Separate sensitivity lists for inputs and outputs
  // Control inputs
  //   always @(MemWriteD or ALUSrcD or RegWriteD or JumpD or BranchD or JalrD or ResultSrcD or ALUControlD or ImmSrcD) begin
  //     $display(
  //         "[%0t] DataPath Control Inputs: MemWriteD=%0b, ALUSrcD=%0b, RegWriteD=%0b, JumpD=%0b, BranchD=%0b, JalrD=%0b, ResultSrcD=%0b, ALUControlD=%0b, ImmSrcD=%0b",
  //         $time, MemWriteD, ALUSrcD, RegWriteD, JumpD, BranchD, JalrD, ResultSrcD, ALUControlD,
  //         ImmSrcD);
  //   end

  //   // Hazard/forwarding inputs
  //   always @(StallF or StallD or FlushD or FlushE or ForwardAE or ForwardBE or PCSrcE) begin
  //     $display(
  //         "[%0t] DataPath Hazard/Forwarding: StallF=%0b, StallD=%0b, FlushD=%0b, FlushE=%0b, ForwardAE=%0b, ForwardBE=%0b, PCSrcE=%0b",
  //         $time, StallF, StallD, FlushD, FlushE, ForwardAE, ForwardBE, PCSrcE);
  //   end

  //   // Control outputs to hazard unit
  //   always @(BranchE or JumpE or JalrE or ZeroE or ALUResultSign or RegWriteM or RegWriteW or ResultSrcE or ResultSrcM or ResultSrcW) begin
  //     $display(
  //         "[%0t] DataPath Control Outputs: BranchE=%0b, JumpE=%0b, JalrE=%0b, ZeroE=%0b, ALUResultSign=%0b, RegWriteM=%0b, RegWriteW=%0b, ResultSrcE=%0b, ResultSrcM=%0b, ResultSrcW=%0b",
  //         $time, BranchE, JumpE, JalrE, ZeroE, ALUResultSign, RegWriteM, RegWriteW, ResultSrcE,
  //         ResultSrcM, ResultSrcW);
  //   end

  //   // Decoded instruction fields
  //   always @(func3D or func3E or func7 or op or Rs1D or Rs2D or Rs1E or Rs2E or RdE or RdM or RdW) begin
  //     $display(
  //         "[%0t] DataPath Instruction Fields: func3D=%0b, func3E=%0b, func7=%0b, op=%0b, Rs1D=%0d, Rs2D=%0d, Rs1E=%0d, Rs2E=%0d, RdE=%0d, RdM=%0d, RdW=%0d",
  //         $time, func3D, func3E, func7, op, Rs1D, Rs2D, Rs1E, Rs2E, RdE, RdM, RdW);
  //   end

  //   // Key internal signals on clock edge
  //   always @(posedge clk) begin
  //     $display(
  //         "[%0t] DataPath Clock Edge - PC=0x%0h, InstrD=0x%0h, InstrF=0x%0h, ALUResultE=0x%0h, ResultW=0x%0h",
  //         $time, PCF, InstrD, InstrF, ALUResultE, ResultW);
  //   end
endmodule
