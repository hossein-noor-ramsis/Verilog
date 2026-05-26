module ALU (
    input signed [31:0] operand_a,
    input signed [31:0] operand_b,
    input [2:0] alu_control,

    output zero_flag,
    output sign_flag,
    output reg signed [31:0] alu_result
);
  assign zero_flag = (alu_result == 32'd0);
  assign sign_flag = alu_result[31];

  always @(*) begin
    case (alu_control)
      3'b000:  alu_result = operand_a + operand_b;
      3'b001:  alu_result = operand_a - operand_b;
      3'b010:  alu_result = operand_a & operand_b;
      3'b011:  alu_result = operand_a | operand_b;
      3'b100:  alu_result = operand_a ^ operand_b;
      3'b101:  alu_result = (operand_a < operand_b) ? 32'd1 : 32'd0;  // SLT
      default: alu_result = 32'd0;
    endcase
  end
endmodule
module Controller (
    input [6:0] opcode,
    input [6:0] funct7,
    input [2:0] funct3,

    input zero_flag,
    input sign_flag,
    input clk,
    input rst,

    output reg       PCWrite,
    output reg       PCWriteCond,
    output reg       OldPCWrite,
    output reg       AdrSrc,
    output reg       MemWrite,
    output reg       IRWrite,
    output reg       RegWrite,
    output reg [1:0] ResultSrc,
    output reg [1:0] ALUSrcA,
    output reg [1:0] ALUSrcB,
    output reg [1:0] ImmSrc,
    output reg [2:0] ALUControl
);
  reg [3:0] state, next_state;

  localparam FETCH = 4'd0;
  localparam DECODE = 4'd1;
  localparam R1 = 4'd2;
  localparam R2 = 4'd3;
  localparam I1 = 4'd4;
  localparam I2 = 4'd5;
  localparam I3 = 4'd14;
  localparam B1 = 4'd6;
  localparam L1 = 4'd7;
  localparam L2 = 4'd8;
  localparam L3 = 4'd9;
  localparam S1 = 4'd10;
  localparam S2 = 4'd11;
  localparam J1 = 4'd12;
  localparam J2 = 4'd13;

  // Opcode definitions
  localparam OP_R_TYPE = 7'b0110011;
  localparam OP_I_TYPE = 7'b0010011;
  localparam OP_LOAD = 7'b0000011;
  localparam OP_JALR = 7'b1100111;
  localparam OP_S_TYPE = 7'b0100011;
  localparam OP_B_TYPE = 7'b1100011;
  localparam OP_JAL = 7'b1101111;

  // ALU Control
  localparam ALU_ADD = 3'b000;
  localparam ALU_SUB = 3'b001;
  localparam ALU_AND = 3'b010;
  localparam ALU_OR = 3'b011;
  localparam ALU_XOR = 3'b100;
  localparam ALU_SLT = 3'b101;

  always @(posedge clk or posedge rst) begin
    if (rst) state <= FETCH;
    else state <= next_state;
  end

  always @(*) begin
    // Default values
    PCWrite     = 1'b0;
    PCWriteCond = 1'b0;
    OldPCWrite  = 1'b0;
    AdrSrc      = 1'b0;
    MemWrite    = 1'b0;
    IRWrite     = 1'b0;
    RegWrite    = 1'b0;
    ResultSrc   = 2'b00;
    ALUSrcA     = 2'b00;
    ALUSrcB     = 2'b00;
    ImmSrc      = 2'b00;
    ALUControl  = ALU_ADD;
    next_state  = FETCH;

    case (state)
      // FETCH: Read instruction from memory, PC += 4
      FETCH: begin
        AdrSrc     = 1'b0;  // Use PC for memory address
        IRWrite    = 1'b1;  // Save instruction to IR
        OldPCWrite = 1'b1;  // Save PC+4 for later
        ALUSrcA    = 2'b00;  // PC
        ALUSrcB    = 2'b10;  // 4
        ALUControl = ALU_ADD;  // PC + 4
        ResultSrc  = 2'b01;  // ALUResult (not registered) to PC
        PCWrite    = 1'b1;  // Update PC
        next_state = DECODE;
      end

      // DECODE: Read registers, pre-compute branch target
      DECODE: begin
        ALUSrcA    = 2'b01;  // OldPC (PC+4 from fetch)
        ALUSrcB    = 2'b01;  // Immediate
        ALUControl = ALU_ADD;  // Pre-compute branch target
        ImmSrc     = 2'b10;  // B-type

        case (opcode)
          OP_R_TYPE: begin
            next_state = R1;
          end
          OP_I_TYPE, OP_JALR: begin
            next_state = I1;
          end
          OP_LOAD: begin
            next_state = L1;
          end
          OP_S_TYPE: begin
            next_state = S1;
          end
          OP_B_TYPE: begin
            next_state = B1;
          end
          OP_JAL: begin
            next_state = J1;
          end
          default: next_state = FETCH;
        endcase
      end

      // R1: R-Type Execute
      R1: begin
        ALUSrcA = 2'b10;  // Register A
        ALUSrcB = 2'b00;  // Register B

        case (funct3)
          3'b000:  ALUControl = funct7[5] ? ALU_SUB : ALU_ADD;
          3'b010:  ALUControl = ALU_SLT;
          3'b100:  ALUControl = ALU_XOR;
          3'b110:  ALUControl = ALU_OR;
          3'b111:  ALUControl = ALU_AND;
          default: ALUControl = ALU_ADD;
        endcase

        next_state = R2;
      end

      // R2: R-Type Write Back
      R2: begin
        ResultSrc  = 2'b00;  // ALUOut (registered)
        RegWrite   = 1'b1;
        next_state = FETCH;
      end

      // I1: I-Type Execute
      I1: begin
        ALUSrcA = 2'b10;  // Register A
        ALUSrcB = 2'b01;  // Immediate
        ImmSrc  = 2'b00;  // I-type immediate

        case (opcode)
          OP_JALR: ALUControl = ALU_ADD;  // RS1 + imm
          default: begin  // OP_I_TYPE
            case (funct3)
              3'b000:  ALUControl = ALU_ADD;
              3'b010:  ALUControl = ALU_SLT;
              3'b100:  ALUControl = ALU_XOR;
              3'b110:  ALUControl = ALU_OR;
              3'b111:  ALUControl = ALU_AND;
              default: ALUControl = ALU_ADD;
            endcase
          end
        endcase

        next_state = I2;
      end

      // I2: I-Type Write Back
      I2: begin
        case (opcode)
          OP_JALR: begin
            ResultSrc  = 2'b11;  // OldPCOut (PC+4) → return address
            RegWrite   = 1'b1;  // Write return address to rd
            next_state = I3;  // Go to jump state
          end
          default: begin
            ResultSrc = 2'b00;  // ALUOut
            RegWrite  = 1'b1;
          end
        endcase

        next_state = FETCH;
      end

      // I3: Jump to target address
      I3: begin
        ResultSrc = 2'b00;  // ALUOut (has RS1+imm from I1)
        PCWrite = 1'b1;  // Jump!
        next_state = FETCH;
      end

      // B1: Branch Execute
      B1: begin
        ALUSrcA    = 2'b10;  // Register A
        ALUSrcB    = 2'b00;  // Register B
        ALUControl = ALU_SUB;  // A - B for comparison

        // Branch condition (branch target is still in ALUOut from DECODE)
        case (funct3)
          3'b000:  PCWriteCond = zero_flag;  // BEQ
          3'b001:  PCWriteCond = ~zero_flag;  // BNE
          3'b100:  PCWriteCond = sign_flag;  // BLT
          3'b101:  PCWriteCond = ~sign_flag;  // BGE
          default: PCWriteCond = 1'b0;
        endcase

        // If branch taken, PC gets ALUOut (branch target from DECODE)
        // But ALUOut will be overwritten by SUB result!
        // SOLUTION: Don't write ALU result to ALUOut in this cycle

        next_state = FETCH;
      end

      // L1: Load Execute (address calculation)
      L1: begin
        ALUSrcA    = 2'b10;  // Register A
        ALUSrcB    = 2'b01;  // Immediate
        ImmSrc     = 2'b00;  // I-type
        ALUControl = ALU_ADD;
        next_state = L2;
      end

      // L2: Load Memory Access
      L2: begin
        AdrSrc     = 1'b1;  // Use ALU result as address
        next_state = L3;
      end

      // L3: Load Write Back
      L3: begin
        ResultSrc  = 2'b10;  // Memory data (MDR)
        RegWrite   = 1'b1;
        next_state = FETCH;
      end

      // S1: Store Execute (address calculation)
      S1: begin
        ALUSrcA    = 2'b10;  // Register A
        ALUSrcB    = 2'b01;  // Immediate
        ImmSrc     = 2'b01;  // S-type
        ALUControl = ALU_ADD;
        next_state = S2;
      end

      // S2: Store Memory Access
      S2: begin
        AdrSrc     = 1'b1;  // ALU result as address
        MemWrite   = 1'b1;  // Write BOut to memory
        next_state = FETCH;
      end

      // J1: JAL - Write return address, compute target
      J1: begin
        // Write return address (OldPCOut) to rd
        ResultSrc  = 2'b11;  // Should be OldPCOut (PC+4)
        RegWrite   = 1'b1;

        // Compute jump target
        ALUSrcA    = 2'b00;  // OldPC
        ALUSrcB    = 2'b01;  // Immediate
        ImmSrc     = 2'b11;  // J-type
        ALUControl = ALU_ADD;

        next_state = J2;
      end

      // J2: JAL - Jump to target
      J2: begin
        ResultSrc  = 2'b00;  // ALUOut (has jump target from J1)
        PCWrite    = 1'b1;
        next_state = FETCH;
      end

      default: next_state = FETCH;
    endcase
  end

endmodule
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
      .in1(ALUOut),  // Use ALUOut for data memory address
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
  Register old_pc_reg (
      .clk(clk),
      .rst(rst),
      .we (OldPCWrite),
      .d  (PCOut + 32'd4),  // Store PC+4 for return address
      .q  (OldPCOut)
  );

  // Instruction Register
  Register IReg (
      .clk(clk),
      .rst(rst),
      .we (IRWrite),
      .d  (MemOut),      // Get instruction from memory
      .q  (Instruction)
  );

  // Memory Data Register
  Register MDReg (
      .clk(clk),
      .rst(rst),
      .we (MemWrite),  // Or dedicated enable from controller
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
  Register AReg (
      .clk(clk),
      .rst(rst),
      .we (1'b1),  // Always loaded, or controlled by state machine
      .d  (RD1),
      .q  (AOut)
  );

  // B Register (holds RD2) - loaded during decode
  Register BReg (
      .clk(clk),
      .rst(rst),
      .we (1'b1),  // Always loaded, or controlled by state machine
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
  Register ALUOutReg (
      .clk(clk),
      .rst(rst),
      .we(1'b1),  // Or controlled by state machine
      .d(ALUResult),
      .q(ALUOut)
  );

  // Result Mux (4-to-1) for writeback
  Mux4To1 ResultMux (
      .in0(ALUOut),
      .in1(ALUResult),
      .in2(MDROut),
      .in3(PCOut),
      .sel(ResultSrc),
      .out(Result)
  );

endmodule
module ImmediateExtend (
    input [31:7] instruction,
    input [ 1:0] imm_src,

    output reg [31:0] imm_extended
);
  always @(*) begin
    case (imm_src)
      // I-type
      2'b00: imm_extended = {{20{instruction[31]}}, instruction[31:20]};

      // S-type
      2'b01: imm_extended = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};

      // B-type
      2'b10:
      imm_extended = {
        {20{instruction[31]}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0
      };

      // J-type
      2'b11:
      imm_extended = {
        {12{instruction[31]}}, instruction[19:12], instruction[20], instruction[30:21], 1'b0
      };

      default: imm_extended = 32'd0;
    endcase
  end
endmodule
module Memory (
    input [31:0] addr,
    input [31:0] write_data,
    input        mem_write,
    input        clk,

    output [31:0] read_data
);
  reg [31:0] mem[0:(2**10 - 1)];  // 1K words = 4KB

  wire [9:0] word_index;
  assign word_index = addr[11:2];  // Byte addr to word index
  // pc is 4x of word index so we shift it to the left by to to divide it to 4

  initial begin
    $readmemh("memory.mem", mem);
  end

  always @(posedge clk) begin
    if (mem_write) mem[word_index] <= write_data;
  end

  assign read_data = mem[word_index];
endmodule
module Mux2To1 (
    input [31:0] in0,
    input [31:0] in1,
    input sel,
    output reg [31:0] out
);
  always @(*) begin
    case (sel)
      1'b0: out = in0;
      1'b1: out = in1;
      default: out = 32'd0;
    endcase
  end
endmodule
module Mux2To1 (
    input [31:0] in0,
    input [31:0] in1,
    input sel,
    output reg [31:0] out
);
  always @(*) begin
    case (sel)
      1'b0: out = in0;
      1'b1: out = in1;
      default: out = 32'd0;
    endcase
  end
endmodule
module Mux3To1 (
    input [31:0] in0,
    input [31:0] in1,
    input [31:0] in2,
    input [1:0] sel,
    output reg [31:0] out
);
  always @(*) begin
    case (sel)
      2'b00:   out = in0;
      2'b01:   out = in1;
      2'b10:   out = in2;
      default: out = 32'd0;
    endcase
  end
endmodule
module Mux4To1 (
    input [31:0] in0,
    input [31:0] in1,
    input [31:0] in2,
    input [31:0] in3,
    input [1:0] sel,
    output reg [31:0] out
);
  always @(*) begin
    case (sel)
      2'b00:   out = in0;
      2'b01:   out = in1;
      2'b10:   out = in2;
      2'b11:   out = in3;
      default: out = 32'd0;  // Safe fallback for X/Z states
    endcase
  end
endmodule
module PC (
    input clk,
    input rst,
    input we,

    input      [31:0] next_pc,
    output reg [31:0] pc = 32'd0
);
  always @(posedge clk) begin
    if (rst) pc <= 32'd0;
    else if (we) pc <= next_pc;
  end
endmodule
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
module Register (
    input             clk,
    input             rst,
    input             we,   // write enable
    input      [31:0] d,
    output reg [31:0] q
);
  always @(posedge clk) begin
    if (rst) q <= 32'd0;
    else if (we) q <= d;
  end
endmodule
module RegisterFile (
    input         clk,
    input         we,          // write enable
    input  [ 4:0] rs1,         // read address 1
    input  [ 4:0] rs2,         // read address 2
    input  [ 4:0] rd,          // write address
    input  [31:0] write_data,
    output [31:0] rd1,         // read data 1
    output [31:0] rd2          // read data 2
);
  reg [31:0] regs[0:31];

  // Initialize all registers to 0
  integer i;
  initial begin
    for (i = 0; i < 32; i = i + 1) begin
      regs[i] = 32'd0;
    end
  end

  // Read (combinational)
  assign rd1 = (rs1 == 5'd0) ? 32'd0 : regs[rs1];
  assign rd2 = (rs2 == 5'd0) ? 32'd0 : regs[rs2];

  // Write (sequential)
  always @(posedge clk) begin
    if (we && (rd != 5'd0)) regs[rd] <= write_data;
  end
endmodule
