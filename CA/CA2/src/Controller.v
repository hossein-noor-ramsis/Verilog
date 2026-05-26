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
  // State encoding (4-bit binary: 0-11 for 12 states)
  reg [3:0] state, next_state;

  localparam FETCH = 4'd0;  // IF
  localparam DECODE = 4'd1;  // ID
  localparam R1 = 4'd2;  // R1
  localparam R2 = 4'd3;  // R2
  localparam I1 = 4'd4;  // I1
  localparam I2 = 4'd5;  // I2
  localparam B1 = 4'd6;  // B1
  localparam L1 = 4'd7;  // L1
  localparam L2 = 4'd8;  // L2
  localparam L3 = 4'd9;  // L3
  localparam S1 = 4'd10;  // S1
  localparam S2 = 4'd11;  // S2
  localparam J1 = 4'd12;
  localparam J2 = 4'd13;

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
    PCWrite     = 1'b0;
    OldPCWrite  = 1'b0;
    AdrSrc      = 1'b0;
    MemWrite    = 1'b0;
    IRWrite     = 1'b0;
    RegWrite    = 1'b0;
    ResultSrc   = 2'b00;
    ALUSrcA     = 2'b00;
    ALUSrcB     = 2'b00;
    ImmSrc      = 2'b00;
    ALUControl  = 3'b000;
    PCWriteCond = 1'b0;
    next_state  = FETCH;

    case (state)
      //////////////////////////////////////////////////////////////////
      // IF: Instruction Fetch
      // AdrSrc=0, IRWrite=1, OldPC=1, ALUSrcA=00, ALUSrcB=10
      // ALUControl=000, ResultSrc=01, PCWrite=1
      //////////////////////////////////////////////////////////////////
      FETCH: begin
        AdrSrc     = 1'b0;
        IRWrite    = 1'b1;
        OldPCWrite = 1'b1;
        ALUSrcA    = 2'b00;
        ALUSrcB    = 2'b10;
        ALUControl = 3'b000;
        ResultSrc  = 2'b01;
        PCWrite    = 1'b1;
        next_state = DECODE;
      end

      //////////////////////////////////////////////////////////////////
      // ID: Instruction Decode
      // ALUSrcA=01, ALUSrcB=01, ImmSrc=10, ALUControl=000
      //////////////////////////////////////////////////////////////////
      DECODE: begin
        ALUSrcA    = 2'b01;
        ALUSrcB    = 2'b01;
        ImmSrc     = 2'b10;
        ALUControl = 3'b000;

        case (opcode)
          OP_R_TYPE: next_state = R1;
          OP_I_TYPE: next_state = I1;
          OP_LOAD:   next_state = L1;
          OP_JALR:   next_state = I1;
          OP_S_TYPE: next_state = S1;
          OP_B_TYPE: next_state = B1;
          OP_JAL:    next_state = I1;
          default:   next_state = FETCH;
        endcase
      end

      //////////////////////////////////////////////////////////////////
      // R1: R-Type Execute
      // ALUSrcA=10, ALUSrcB=00
      //////////////////////////////////////////////////////////////////
      R1: begin
        ALUSrcA = 2'b10;
        ALUSrcB = 2'b00;

        case (funct3)
          3'b000:  ALUControl = funct7[5] ? 3'b001 : 3'b000;  // SUB/ADD
          3'b010:  ALUControl = 3'b101;  // SLT
          3'b100:  ALUControl = 3'b100;  // XOR
          3'b111:  ALUControl = 3'b010;  // AND
          3'b110:  ALUControl = 3'b011;  // OR
          default: ALUControl = 3'b000;
        endcase

        next_state = R2;
      end

      //////////////////////////////////////////////////////////////////
      // R2: R-Type Write Back
      // ResultSrc=00, RegWrite=1
      //////////////////////////////////////////////////////////////////
      R2: begin
        ResultSrc  = 2'b00;
        RegWrite   = 1'b1;
        next_state = FETCH;
      end

      //////////////////////////////////////////////////////////////////
      // I1: I-Type/Jump Execute
      //////////////////////////////////////////////////////////////////
      I1: begin
        case (opcode)
          OP_JALR: begin
            ALUSrcA    = 2'b10;
            ALUSrcB    = 2'b01;
            ImmSrc     = 2'b00;
            ALUControl = 3'b000;
          end

          default: begin
            ALUSrcA = 2'b10;
            ALUSrcB = 2'b01;
            ImmSrc  = 2'b00;

            case (funct3)
              3'b000:  ALUControl = 3'b000;
              3'b010:  ALUControl = 3'b101;
              3'b100:  ALUControl = 3'b100;
              3'b111:  ALUControl = 3'b010;
              3'b110:  ALUControl = 3'b011;
              default: ALUControl = 3'b000;
            endcase
          end
        endcase

        next_state = I2;
      end

      //////////////////////////////////////////////////////////////////
      // I2: I-Type/Jump Write Back
      //////////////////////////////////////////////////////////////////
      I2: begin
        case (opcode)
          OP_JALR: begin
            ResultSrc = 2'b01;
            PCWrite   = 1'b1;
            RegWrite  = 1'b1;
          end

          default: begin
            ResultSrc = 2'b00;
            RegWrite  = 1'b1;
          end
        endcase

        next_state = FETCH;
      end

      //////////////////////////////////////////////////////////////////
      // B1: Branch Execute
      // ALUSrcA=10, ALUSrcB=00, ALUControl=001, PCWriteCond=1, ResultSrc = 00
      //////////////////////////////////////////////////////////////////
      B1: begin
        ALUSrcA     = 2'b10;
        ALUSrcB     = 2'b00;
        ALUControl  = 3'b001;
        PCWriteCond = 1'b1;
        ResultSrc   = 2'b00;

        next_state  = FETCH;
      end

      //////////////////////////////////////////////////////////////////
      // L1: Load Execute
      // ALUSrcA=10, ALUSrcB=00, ImmSrc=00, ALUControl=000
      //////////////////////////////////////////////////////////////////
      L1: begin
        ALUSrcA    = 2'b10;
        ALUSrcB    = 2'b00;
        ImmSrc     = 2'b00;
        ALUControl = 3'b000;
        next_state = L2;
      end

      //////////////////////////////////////////////////////////////////
      // L2: Load Memory Access
      // ResultSrc=00, AdrSrc=1
      //////////////////////////////////////////////////////////////////
      L2: begin
        ResultSrc  = 2'b00;
        AdrSrc     = 1'b1;
        next_state = L3;
      end

      //////////////////////////////////////////////////////////////////
      // L3: Load Write Back
      // ResultSrc=10, RegWrite=1
      //////////////////////////////////////////////////////////////////
      L3: begin
        ResultSrc  = 2'b10;
        RegWrite   = 1'b1;
        next_state = FETCH;
      end

      //////////////////////////////////////////////////////////////////
      // S1: Store Execute
      // ALUSrcA=10, ALUSrcB=01, ImmSrc=01, ALUControl=000
      //////////////////////////////////////////////////////////////////
      S1: begin
        ALUSrcA    = 2'b10;
        ALUSrcB    = 2'b01;
        ImmSrc     = 2'b01;
        ALUControl = 3'b000;
        next_state = S2;
      end

      //////////////////////////////////////////////////////////////////
      // S2: Store Write Back
      // ResultSrc=00, AdrSrc=0, MemWrite=1
      //////////////////////////////////////////////////////////////////
      S2: begin
        ResultSrc  = 2'b00;
        AdrSrc     = 1'b1;
        MemWrite   = 1'b1;
        next_state = FETCH;
      end

      default: next_state = FETCH;
    endcase
  end

endmodule
