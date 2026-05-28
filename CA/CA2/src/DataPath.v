module DataPath (
    input clk,
    input rst,
    input PCWrite,
    input PCWriteCond,
    input OldPCWrite,
    input AdrSrc,
    input MemWrite,
    input IRWrite,
    input RegWrite,

    input [1:0] ResultSrc,
    input [1:0] ALUSrcA,
    input [1:0] ALUSrcB,

    input [2:0] ALUControl,
    input [1:0] ImmSrc,

    output zero,
    output sign,

    output [6:0] func7,
    output [2:0] func3,
    output [6:0] opcode
);
  // Instruction signals
  wire [31:0] Instruction;

  // Register file signals
  wire [31:0] RD1, RD2;
  wire [4:0] rs1, rs2, rd;

  // ALU signals
  wire signed [31:0] ALUOperandA, ALUOperandB;
  wire [31:0] ALUResult, ImmExtended, ALUOut;

  // Data memory signals
  wire [31:0] MemOut, Address;
  wire [31:0] PCOut, OldPCOut;

  // Intermediate registers outputs
  wire [31:0] AOut, BOut;
  wire [31:0] MDROut;
  wire [31:0] Result;

  // Instruction decoding
  assign opcode = Instruction[6:0];
  assign func3 = Instruction[14:12];
  assign func7 = Instruction[31:25];
  assign rs1 = Instruction[19:15];
  assign rs2 = Instruction[24:20];
  assign rd = Instruction[11:7];

  // PC Write logic
  wire PCWriteFinal;
  assign PCWriteFinal = PCWrite | PCWriteCond;

  PC program_counter (
      .clk(clk),
      .rst(rst),
      .we(PCWriteFinal),
      .next_pc(Result),
      .pc(PCOut)
  );

  // Address Mux for Memory
  Mux2To1 address_mux (
      .in0(PCOut),
      .in1(Result),
      .sel(AdrSrc),
      .out(Address)
  );

  // Memory (unified instruction/data memory)
  Memory memory (
      .addr(Address),
      .write_data(BOut),     // From B register
      .mem_write(MemWrite),
      .clk(clk),
      .read_data(MemOut)
  );

  // Old PC Register (for JAL return address)
  Register #("OldPCReg") OldPCReg (
      .clk(clk),
      .rst(rst),
      .we (OldPCWrite),
      .d  (PCOut),
      .q  (OldPCOut)
  );

  // Instruction Register
  Register #("IReg") IReg (
      .clk(clk),
      .rst(rst),
      .we (IRWrite),     // bug
      .d  (MemOut),      // Get instruction from memory
      .q  (Instruction)
  );

  // Memory Data Register
  Register #("MDReg") MDReg (
      .clk(clk),
      .rst(rst),
      .we (1'b1),
      .d  (MemOut),
      .q  (MDROut)
  );

  // Register File
  RegisterFile RF (
      .clk(clk),
      .we(RegWrite),  // bug
      .rs1(rs1),
      .rs2(rs2),
      .rd(rd),
      .write_data(Result),
      .rd1(RD1),
      .rd2(RD2)
  );

  // Immediate Extension
  ImmediateExtend ImmExt (
      .instruction(Instruction[31:7]),
      .imm_src(ImmSrc),
      .imm_extended(ImmExtended)
  );

  // A Register (holds RD1) - loaded during decode
  Register #("AReg") AReg (
      .clk(clk),
      .rst(rst),
      .we (1'b1),
      .d  (RD1),
      .q  (AOut)
  );

  // B Register (holds RD2) - loaded during decode
  Register #("BReg") BReg (
      .clk(clk),
      .rst(rst),
      .we (1'b1),
      .d  (RD2),
      .q  (BOut)
  );

  // ALU Operand A Mux (3-to-1)
  Mux3To1 alu_a_mux (
      .in0(PCOut),       // For PC-relative operations
      .in1(OldPCOut),    // For JAL return address calculation
      .in2(AOut),        // From register file
      .sel(ALUSrcA),
      .out(ALUOperandA)
  );

  // ALU Operand B Mux (3-to-1)
  Mux3To1 alu_b_mux (
      .in0(BOut),         // From register file
      .in1(ImmExtended),  // Immediate value
      .in2(32'd4),        // For PC+4
      .sel(ALUSrcB),
      .out(ALUOperandB)
  );

  // ALU
  ALU alu (
      .operand_a  (ALUOperandA),
      .operand_b  (ALUOperandB),
      .alu_control(ALUControl),
      .zero_flag  (zero),
      .sign_flag  (sign),
      .alu_result (ALUResult)
  );

  // ALU Output Register
  Register #("ALUOutReg") ALUOutReg (
      .clk(clk),
      .rst(rst),
      .we (1'b1),
      .d  (ALUResult),
      .q  (ALUOut)
  );

  // Result Mux (4-to-1) for writeback
  Mux3To1 ResultMux (
      .in0(ALUOut),
      .in1(ALUResult),
      .in2(MDROut),
      .sel(ResultSrc),
      .out(Result)
  );

endmodule
