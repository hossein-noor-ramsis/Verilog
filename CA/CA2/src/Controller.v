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

        case (opcode)
          OP_R_TYPE: begin
            ImmSrc     = 2'b00;  // Not used but set default
            next_state = R1;
          end
          OP_I_TYPE, OP_JALR: begin
            ImmSrc     = 2'b00;  // I-type
            next_state = I1;
          end
          OP_LOAD: begin
            ImmSrc     = 2'b00;  // I-type
            next_state = L1;
          end
          OP_S_TYPE: begin
            ImmSrc     = 2'b01;  // S-type
            next_state = S1;
          end
          OP_B_TYPE: begin
            ImmSrc     = 2'b10;  // B-type
            next_state = B1;
          end
          OP_JAL: begin
            ImmSrc     = 2'b11;  // J-type
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
        ALUSrcA    = 2'b01;  // OldPC
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
