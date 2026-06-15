module IF_ID_Regs (
    input clk,
    sclr,
    en,
    input [31:0] InstrF,
    PCF,
    PCPlus4F,
    output [31:0] InstrD,
    PCD,
    PCPlus4D
);
  Register R33 (
      clk,
      en,
      sclr,
      InstrF,
      InstrD
  );
  Register R34 (
      clk,
      en,
      sclr,
      PCF,
      PCD
  );
  Register R35 (
      clk,
      en,
      sclr,
      PCPlus4F,
      PCPlus4D
  );

  //   // Separate sensitivity lists for inputs and outputs
  //   always @(InstrF or PCF or PCPlus4F) begin
  //     $display("[%0t] IF_ID Input Change: InstrF=0x%0h, PCF=0x%0h, PCPlus4F=0x%0h", $time, InstrF,
  //              PCF, PCPlus4F);
  //   end

  //   always @(InstrD or PCD or PCPlus4D) begin
  //     $display("[%0t] IF_ID Output Change: InstrD=0x%0h, PCD=0x%0h, PCPlus4D=0x%0h", $time, InstrD,
  //              PCD, PCPlus4D);
  //   end
endmodule


module ID_EX_Regs (
    input clk,
    sclr,
    RegWriteD,
    MemWriteD,
    ALUSrcD,
    JumpD,
    BranchD,
    JalrD,
    input [1:0] ResultSrcD,
    input [2:0] ALUControlD,
    func3D,
    input [4:0] Rs1D,
    Rs2D,
    RdD,
    input [31:0] PCD,
    ExtImmD,
    PCPlus4D,
    RD1D,
    RD2D,
    output RegWriteE,
    MemWriteE,
    ALUSrcE,
    JumpE,
    BranchE,
    JalrE,
    output [1:0] ResultSrcE,
    output [2:0] ALUControlE,
    func3E,
    output [4:0] Rs1E,
    Rs2E,
    RdE,
    output [31:0] PCE,
    ExtImmE,
    PCPlus4E,
    RD1E,
    RD2E
);
  Register #(1) R1 (
      clk,
      1'b1,
      sclr,
      RegWriteD,
      RegWriteE
  );
  Register #(1) R2 (
      clk,
      1'b1,
      sclr,
      MemWriteD,
      MemWriteE
  );
  Register #(1) R3 (
      clk,
      1'b1,
      sclr,
      JumpD,
      JumpE
  );
  Register #(1) R4 (
      clk,
      1'b1,
      sclr,
      ALUSrcD,
      ALUSrcE
  );
  Register #(1) R5 (
      clk,
      1'b1,
      sclr,
      BranchD,
      BranchE
  );
  Register #(1) R6 (
      clk,
      1'b1,
      sclr,
      JalrD,
      JalrE
  );
  Register #(2) R7 (
      clk,
      1'b1,
      sclr,
      ResultSrcD,
      ResultSrcE
  );
  Register #(3) R8 (
      clk,
      1'b1,
      sclr,
      ALUControlD,
      ALUControlE
  );
  Register #(3) R9 (
      clk,
      1'b1,
      sclr,
      func3D,
      func3E
  );
  Register #(5) R10 (
      clk,
      1'b1,
      sclr,
      Rs1D,
      Rs1E
  );
  Register #(5) R11 (
      clk,
      1'b1,
      sclr,
      Rs2D,
      Rs2E
  );
  Register #(5) R12 (
      clk,
      1'b1,
      sclr,
      RdD,
      RdE
  );
  Register R13 (
      clk,
      1'b1,
      sclr,
      PCD,
      PCE
  );
  Register R14 (
      clk,
      1'b1,
      sclr,
      ExtImmD,
      ExtImmE
  );
  Register R15 (
      clk,
      1'b1,
      sclr,
      PCPlus4D,
      PCPlus4E
  );
  Register R16 (
      clk,
      1'b1,
      sclr,
      RD1D,
      RD1E
  );
  Register R17 (
      clk,
      1'b1,
      sclr,
      RD2D,
      RD2E
  );

  //   // Separate sensitivity lists for inputs and outputs
  //   always @(RegWriteD or MemWriteD or ALUSrcD or JumpD or BranchD or JalrD or ResultSrcD or ALUControlD or func3D or Rs1D or Rs2D or RdD or PCD or ExtImmD or PCPlus4D or RD1D or RD2D) begin
  //     $display(
  //         "[%0t] ID_EX Input Change: RegWriteD=%0b, MemWriteD=%0b, ALUSrcD=%0b, JumpD=%0b, BranchD=%0b, JalrD=%0b, ResultSrcD=%0b, ALUControlD=%0b, func3D=%0b",
  //         $time, RegWriteD, MemWriteD, ALUSrcD, JumpD, BranchD, JalrD, ResultSrcD, ALUControlD,
  //         func3D);
  //     $display(
  //         "[%0t] ID_EX Registers: Rs1D=%0d, Rs2D=%0d, RdD=%0d, PCD=0x%0h, ExtImmD=0x%0h, RD1D=0x%0h, RD2D=0x%0h",
  //         $time, Rs1D, Rs2D, RdD, PCD, ExtImmD, RD1D, RD2D);
  //   end

  //   always @(RegWriteE or MemWriteE or ALUSrcE or JumpE or BranchE or JalrE or ResultSrcE or ALUControlE or func3E or Rs1E or Rs2E or RdE or PCE or ExtImmE or PCPlus4E or RD1E or RD2E) begin
  //     $display(
  //         "[%0t] ID_EX Output Change: RegWriteE=%0b, MemWriteE=%0b, ALUSrcE=%0b, JumpE=%0b, BranchE=%0b, JalrE=%0b, ResultSrcE=%0b, ALUControlE=%0b, func3E=%0b",
  //         $time, RegWriteE, MemWriteE, ALUSrcE, JumpE, BranchE, JalrE, ResultSrcE, ALUControlE,
  //         func3E);
  //     $display(
  //         "[%0t] ID_EX Registers: Rs1E=%0d, Rs2E=%0d, RdE=%0d, PCE=0x%0h, ExtImmE=0x%0h, RD1E=0x%0h, RD2E=0x%0h",
  //         $time, Rs1E, Rs2E, RdE, PCE, ExtImmE, RD1E, RD2E);
  //   end
endmodule

module EX_Mem_Regs (
    input clk,
    RegWriteE,
    MemWriteE,
    input [1:0] ResultSrcE,
    input [4:0] RdE,
    input [31:0] ALUResultE,
    WriteDataE,
    ExtImmE,
    PCPlus4E,
    output RegWriteM,
    MemWriteM,
    output [1:0] ResultSrcM,
    output [4:0] RdM,
    output [31:0] ALUResultM,
    WriteDataM,
    ExtImmM,
    PCPlus4M
);
  Register #(1) R18 (
      clk,
      1'b1,
      1'b0,
      RegWriteE,
      RegWriteM
  );
  Register #(1) R19 (
      clk,
      1'b1,
      1'b0,
      MemWriteE,
      MemWriteM
  );
  Register #(2) R20 (
      clk,
      1'b1,
      1'b0,
      ResultSrcE,
      ResultSrcM
  );
  Register #(5) R21 (
      clk,
      1'b1,
      1'b0,
      RdE,
      RdM
  );
  Register R22 (
      clk,
      1'b1,
      1'b0,
      ALUResultE,
      ALUResultM
  );
  Register R23 (
      clk,
      1'b1,
      1'b0,
      WriteDataE,
      WriteDataM
  );
  Register R24 (
      clk,
      1'b1,
      1'b0,
      ExtImmE,
      ExtImmM
  );
  Register R25 (
      clk,
      1'b1,
      1'b0,
      PCPlus4E,
      PCPlus4M
  );

  //   // Separate sensitivity lists for inputs and outputs
  //   always @(RegWriteE or MemWriteE or ResultSrcE or RdE or ALUResultE or WriteDataE or ExtImmE or PCPlus4E) begin
  //     $display(
  //         "[%0t] EX_Mem Input Change: RegWriteE=%0b, MemWriteE=%0b, ResultSrcE=%0b, RdE=%0d, ALUResultE=0x%0h, WriteDataE=0x%0h, ExtImmE=0x%0h, PCPlus4E=0x%0h",
  //         $time, RegWriteE, MemWriteE, ResultSrcE, RdE, ALUResultE, WriteDataE, ExtImmE, PCPlus4E);
  //   end

  //   always @(RegWriteM or MemWriteM or ResultSrcM or RdM or ALUResultM or WriteDataM or ExtImmM or PCPlus4M) begin
  //     $display(
  //         "[%0t] EX_Mem Output Change: RegWriteM=%0b, MemWriteM=%0b, ResultSrcM=%0b, RdM=%0d, ALUResultM=0x%0h, WriteDataM=0x%0h, ExtImmM=0x%0h, PCPlus4M=0x%0h",
  //         $time, RegWriteM, MemWriteM, ResultSrcM, RdM, ALUResultM, WriteDataM, ExtImmM, PCPlus4M);
  //   end
endmodule


module Mem_WB_Regs (
    input clk,
    RegWriteM,
    input [1:0] ResultSrcM,
    input [4:0] RdM,
    input [31:0] ALUResultM,
    ReadDataM,
    ExtImmM,
    PCPlus4M,
    output RegWriteW,
    output [1:0] ResultSrcW,
    input [4:0] RdW,
    output [31:0] ALUResultW,
    ReadDataW,
    ExtImmW,
    PCPlus4W
);
  Register #(1) R26 (
      clk,
      1'b1,
      1'b0,
      RegWriteM,
      RegWriteW
  );
  Register #(2) R27 (
      clk,
      1'b1,
      1'b0,
      ResultSrcM,
      ResultSrcW
  );
  Register #(5) R28 (
      clk,
      1'b1,
      1'b0,
      RdM,
      RdW
  );
  Register R29 (
      clk,
      1'b1,
      1'b0,
      ALUResultM,
      ALUResultW
  );
  Register R30 (
      clk,
      1'b1,
      1'b0,
      ReadDataM,
      ReadDataW
  );
  Register R31 (
      clk,
      1'b1,
      1'b0,
      ExtImmM,
      ExtImmW
  );
  Register R32 (
      clk,
      1'b1,
      1'b0,
      PCPlus4M,
      PCPlus4W
  );

  // // Separate sensitivity lists for inputs and outputs
  //   always @(RegWriteM or ResultSrcM or RdM or ALUResultM or ReadDataM or ExtImmM or PCPlus4M) begin
  //     $display(
  //         "[%0t] Mem_WB Input Change: RegWriteM=%0b, ResultSrcM=%0b, RdM=%0d, ALUResultM=0x%0h, ReadDataM=0x%0h, ExtImmM=0x%0h, PCPlus4M=0x%0h",
  //         $time, RegWriteM, ResultSrcM, RdM, ALUResultM, ReadDataM, ExtImmM, PCPlus4M);
  //   end

  //   always @(RegWriteW or ResultSrcW or RdW or ALUResultW or ReadDataW or ExtImmW or PCPlus4W) begin
  //     $display(
  //         "[%0t] Mem_WB Output Change: RegWriteW=%0b, ResultSrcW=%0b, RdW=%0d, ALUResultW=0x%0h, ReadDataW=0x%0h, ExtImmW=0x%0h, PCPlus4W=0x%0h",
  //         $time, RegWriteW, ResultSrcW, RdW, ALUResultW, ReadDataW, ExtImmW, PCPlus4W);
  //   end
endmodule
