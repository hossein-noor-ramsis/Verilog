module Controller (
    input [6:0] opcode,
    input [2:0] funct3,
    input funct7_5,
    input zero_flag,
    input sign_flag,
    input clk,
    input rst,

    // Datapath control signals
    output reg PCWrite,
    output reg OldPCWrite,
    output reg AdrSrc,
    output reg MemWrite,
    output reg IRWrite,
    output reg RegWrite,
    output reg [1:0] ResultSrc,
    output reg [1:0] ALUSrcA,
    output reg [1:0] ALUSrcB,
    output reg [2:0] ImmSrc,
    output reg [2:0] ALUControl
);

  // State encoding (one-hot for simplicity)
  reg [7:0] state, next_state;

  localparam FETCH = 8'b00000001;
  localparam DECODE = 8'b00000010;
  localparam EXECUTE_R = 8'b00000100;
  localparam EXECUTE_I = 8'b00001000;
  localparam EXECUTE_S = 8'b00010000;
  localparam EXECUTE_B = 8'b00100000;
  localparam EXECUTE_J = 8'b01000000;
  localparam WB = 8'b10000000;

  // Opcode definitions
  localparam OP_R_TYPE = 7'b0110011;
  localparam OP_I_TYPE = 7'b0010011;  // addi, xori, ori, slti
  localparam OP_LOAD = 7'b0000011;  // lw
  localparam OP_JALR = 7'b1100111;  // jalr
  localparam OP_S_TYPE = 7'b0100011;  // sw
  localparam OP_B_TYPE = 7'b1100011;  // beq, bne, blt, bge
  localparam OP_JAL = 7'b1101111;  // jal

  // State machine
  always @(posedge clk or posedge rst) begin
    if (rst) state <= FETCH;
    else state <= next_state;
  end

  // Next state and control logic
  always @(*) begin
    // Default values (all inactive)
    PCWrite = 1'b0;
    OldPCWrite = 1'b0;
    AdrSrc = 1'b0;
    MemWrite = 1'b0;
    IRWrite = 1'b0;
    RegWrite = 1'b0;
    ResultSrc = 2'b00;
    ALUSrcA = 2'b00;
    ALUSrcB = 2'b00;
    ImmSrc = 3'b000;
    ALUControl = 3'b010;  // Default ADD
    next_state = FETCH;

    case (state)
      FETCH: begin
        // Fetch instruction from memory
        AdrSrc     = 1'b0;  // Use PC for address
        IRWrite    = 1'b1;  // Save instruction
        ALUSrcA    = 2'b00;  // PC
        ALUSrcB    = 2'b10;  // 4
        ALUControl = 3'b010;  // ADD (PC + 4)
        ResultSrc  = 2'b11;  // ALU result to PC
        PCWrite    = 1'b1;  // Update PC
        next_state = DECODE;
      end

      DECODE: begin
        OldPCWrite = 1'b1;  // Save PC for JAL/JALR
        ALUSrcA    = 2'b00;  // PC
        ALUSrcB    = 2'b10;  // 4
        ALUControl = 3'b010;  // ADD (PC + 4)

        // Decode next state based on opcode
        case (opcode)
          OP_R_TYPE: next_state = EXECUTE_R;
          OP_I_TYPE: next_state = EXECUTE_I;
          OP_LOAD:   next_state = EXECUTE_I;
          OP_JALR:   next_state = EXECUTE_I;
          OP_S_TYPE: next_state = EXECUTE_S;
          OP_B_TYPE: next_state = EXECUTE_B;
          OP_JAL:    next_state = EXECUTE_J;
          default:   next_state = FETCH;
        endcase
      end

      EXECUTE_R: begin
        ALUSrcA = 2'b10;  // Register A
        ALUSrcB = 2'b00;  // Register B

        // ALU control for R-type
        case (funct3)
          3'b000:  ALUControl = funct7_5 ? 3'b110 : 3'b010;  // SUB/ADD
          3'b010:  ALUControl = 3'b111;  // SLT
          3'b100:  ALUControl = 3'b011;  // XOR
          3'b110:  ALUControl = 3'b001;  // OR
          3'b111:  ALUControl = 3'b000;  // AND
          default: ALUControl = 3'b010;  // ADD
        endcase

        next_state = WB;
      end

      EXECUTE_I: begin
        ALUSrcA = 2'b10;  // Register A
        ALUSrcB = 2'b01;  // Immediate
        ImmSrc  = 3'b000;  // I-type immediate

        // ALU control for I-type
        case (opcode)
          OP_LOAD: begin
            ALUControl = 3'b010;  // ADD for lw address
            next_state = EXECUTE_S;  // Will go to memory read
          end

          OP_JALR: begin
            ALUControl = 3'b010;  // ADD for jalr target
            next_state = WB;
          end

          default: begin  // OP_I_TYPE (addi, xori, ori, slti)
            case (funct3)
              3'b000:  ALUControl = 3'b010;  // ADDI
              3'b010:  ALUControl = 3'b111;  // SLTI
              3'b100:  ALUControl = 3'b011;  // XORI
              3'b110:  ALUControl = 3'b001;  // ORI
              default: ALUControl = 3'b010;  // ADD
            endcase
            next_state = WB;
          end
        endcase
      end

      EXECUTE_S: begin
        case (opcode)
          OP_LOAD: begin
            // Memory read for lw
            AdrSrc     = 1'b1;  // Use ALU result as address
            MemWrite   = 1'b0;
            next_state = WB;
          end

          OP_S_TYPE: begin
            // Calculate address for sw
            ALUSrcA    = 2'b10;  // Register A
            ALUSrcB    = 2'b01;  // Immediate
            ImmSrc     = 3'b001;  // S-type immediate
            ALUControl = 3'b010;  // ADD
            next_state = WB;  // In WB, actually do memory write
          end

          default: next_state = FETCH;
        endcase
      end

      EXECUTE_B: begin
        ALUSrcA    = 2'b10;  // Register A
        ALUSrcB    = 2'b00;  // Register B
        ALUControl = 3'b110;  // SUB for comparison

        // Branch decision
        case (funct3)
          3'b000:  if (zero_flag) PCWrite = 1'b1;  // BEQ
          3'b001:  if (!zero_flag) PCWrite = 1'b1;  // BNE
          3'b100:  if (sign_flag) PCWrite = 1'b1;  // BLT
          3'b101:  if (!sign_flag) PCWrite = 1'b1;  // BGE
          default: PCWrite = 1'b0;
        endcase

        if (PCWrite) begin
          ALUSrcA    = 2'b00;  // PC
          ALUSrcB    = 2'b01;  // Immediate (branch offset)
          ImmSrc     = 3'b010;  // B-type immediate
          ALUControl = 3'b010;  // ADD (PC + offset)
          ResultSrc  = 2'b11;  // ALU result to PC
        end

        next_state = FETCH;
      end

      EXECUTE_J: begin
        ALUSrcA    = 2'b00;  // PC
        ALUSrcB    = 2'b01;  // Immediate
        ImmSrc     = 3'b100;  // J-type immediate
        ALUControl = 3'b010;  // ADD (PC + offset)
        ResultSrc  = 2'b11;  // ALU result to PC
        PCWrite    = 1'b1;  // Update PC

        next_state = WB;
      end

      WB: begin  // Write Back
        case (opcode)
          OP_R_TYPE: begin
            RegWrite  = 1'b1;
            ResultSrc = 2'b00;  // ALU result
          end

          OP_I_TYPE: begin
            RegWrite  = 1'b1;
            ResultSrc = 2'b00;  // ALU result
          end

          OP_LOAD: begin
            RegWrite  = 1'b1;
            ResultSrc = 2'b01;  // Memory data
          end

          OP_JALR: begin
            RegWrite  = 1'b1;
            ResultSrc = 2'b11;  // PC + 4 (return address)
          end

          OP_JAL: begin
            RegWrite  = 1'b1;
            ResultSrc = 2'b11;  // PC + 4 (return address)
          end

          OP_S_TYPE: begin
            // Memory write for sw
            AdrSrc   = 1'b1;  // Use ALU result as address
            MemWrite = 1'b1;
          end

          default: RegWrite = 1'b0;
        endcase

        next_state = FETCH;
      end

      default: next_state = FETCH;
    endcase
  end

endmodule
