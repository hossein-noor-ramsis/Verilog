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
    input [2:0] ImmSrc,

    output zero,
    output sign,

    output [6:0] func7,
    output [2:0] func3,
    output [6:0] opcode
);
  // Instruction signals
  wire [31:0] Instruction;
  wire [31:7] InstructionImm;

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
  wire [31:0] MDROut;  // Memory Data Register output
  wire [31:0] Result;

  // Instruction decoding
  assign opcode = Instruction[6:0];
  assign func3 = Instruction[14:12];
  assign func7 = Instruction[31:25];
  assign rs1 = Instruction[19:15];
  assign rs2 = Instruction[24:20];
  assign rd = Instruction[11:7];

  // PC Write logic
  wire PCWriteCond_and_zero, PCWrite_final;
  and (PCWriteCond_and_zero, PCWriteCond, zero);
  or (PCWrite_final, PCWriteCond_and_zero, PCWrite);

  // Instantiate PC
  PC program_counter (
      .clk(clk),
      .rst(rst),
      .we(PCWrite_final),  // Fixed: was w2
      .next_pc(Result),
      .pc(PCOut)
  );

  // Address Mux for Memory
  Mux2To1 address_mux (
      .in0(PCOut),
      .in1(ALUOut),  // Use ALUOut for data memory address
      .sel(AdrSrc),
      .out(Address)
  );

  // Memory (unified instruction/data memory for simplicity)
  Memory memory (
      .addr(Address),
      .write_data(BOut),     // From B register
      .mem_write(MemWrite),
      .clk(clk),
      .read_data(MemOut)
  );

  // Old PC Register (for JAL return address)
  RegisterWithEnable old_pc_reg (
      .clk(clk),
      .we (OldPCWrite),
      .d  (PCOut),       // Was missing input
      .q  (OldPCOut)
  );

  // Instruction Register
  RegisterWithEnable IReg (
      .clk(clk),
      .we (IRWrite),
      .d  (MemOut),      // Get instruction from memory
      .q  (Instruction)
  );

  // Memory Data Register
  Register MDReg (
      .clk(clk),
      .d  (MemOut),
      .q  (MDROut)
  );

  // Register File
  RegisterFile RF (
      .clk(clk),
      .we(RegWrite),
      .rs1(rs1),
      .rs2(rs2),
      .rd(rd),
      .write_data(Result),  // Added write data
      .rd1(RD1),
      .rd2(RD2)
  );

  // Immediate Extension
  ImmediateExtend ImmExt (
      .instruction(InstructionImm),
      .imm_src(ImmSrc),
      .imm_extended(ImmExtended)
  );

  // A Register (holds RD1)
  Register AReg (
      .clk(clk),
      .d  (RD1),
      .q  (AOut)
  );

  // B Register (holds RD2)
  Register BReg (
      .clk(clk),
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

  // ALU Operand B Mux (3-to-1) - Fixed: was named same as previous mux
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
  Register ALUOutReg (
      .clk(clk),
      .d  (ALUResult),
      .q  (ALUOut)
  );

  // Result Mux (4-to-1) for writeback
  Mux4To1 ResultMux (
      .in0(ALUOut),         // ALU result
      .in1(MDROut),         // Memory data
      .in2(ALUResult),      // Direct ALU result (for branches)
      .in3(PCOut + 32'd4),  // PC+4 for JAL
      .sel(ResultSrc),
      .out(Result)
  );

endmodule
