module Processor (
    input clk,
    input rst
);
  wire PCWrite, PCWriteCond, OldPCWrite, AdrSrc, MemWrite, IRWrite, RegWrite;
  wire [1:0] ResultSrc, ALUSrcA, ALUSrcB, ImmSrc;
  wire [2:0] ALUControl;
  wire zero, sign;
  wire [6:0] func7, opcode;
  wire [2:0] func3;

  // Controller
  Controller controller (
      .opcode(opcode),
      .funct3(func3),
      .funct7(func7),
      .zero_flag(zero),
      .sign_flag(sign),
      .clk(clk),
      .rst(rst),
      .PCWrite(PCWrite),
      .PCWriteCond(PCWriteCond),
      .OldPCWrite(OldPCWrite),
      .AdrSrc(AdrSrc),
      .MemWrite(MemWrite),
      .IRWrite(IRWrite),
      .RegWrite(RegWrite),
      .ResultSrc(ResultSrc),
      .ALUSrcA(ALUSrcA),
      .ALUSrcB(ALUSrcB),
      .ImmSrc(ImmSrc),
      .ALUControl(ALUControl)
  );

  // Datapath
  DataPath datapath (
      .clk(clk),
      .rst(rst),
      .PCWrite(PCWrite),
      .PCWriteCond(PCWriteCond),
      .OldPCWrite(OldPCWrite),
      .AdrSrc(AdrSrc),
      .MemWrite(MemWrite),
      .IRWrite(IRWrite),
      .RegWrite(RegWrite),
      .ResultSrc(ResultSrc),
      .ALUSrcA(ALUSrcA),
      .ALUSrcB(ALUSrcB),
      .ALUControl(ALUControl),
      .ImmSrc(ImmSrc),
      .zero(zero),
      .sign(sign),
      .func7(func7),
      .func3(func3),
      .opcode(opcode)
  );

endmodule
