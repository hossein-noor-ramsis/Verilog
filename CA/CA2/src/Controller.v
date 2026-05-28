module Controller (
    input [6:0] opcode,
    input [6:0] func7,
    input [2:0] func3,

    input zero,
    input sign,
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
  localparam J3 = 4'd15;

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

  // Function to get state name as string
  function [63:0] state_name;
    input [3:0] s;
    begin
      case (s)
        FETCH:   state_name = "FETCH";
        DECODE:  state_name = "DECODE";
        R1:      state_name = "R1";
        R2:      state_name = "R2";
        I1:      state_name = "I1";
        I2:      state_name = "I2";
        I3:      state_name = "I3";
        B1:      state_name = "B1";
        L1:      state_name = "L1";
        L2:      state_name = "L2";
        L3:      state_name = "L3";
        S1:      state_name = "S1";
        S2:      state_name = "S2";
        J1:      state_name = "J1";
        J2:      state_name = "J2";
        J3:      state_name = "J3";
        default: state_name = "UNKNOWN";
      endcase
    end
  endfunction

  always @(posedge clk or posedge rst) begin
    if (rst) state <= FETCH;
    else begin
      state <= next_state;
      $display("Controller: State = %0s -> %0s", state_name(state), state_name(next_state));
    end
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
      FETCH: begin
        AdrSrc     = 1'b0;
        IRWrite    = 1'b1;
        OldPCWrite = 1'b1;
        ALUSrcA    = 2'b00;
        ALUSrcB    = 2'b10;
        ALUControl = ALU_ADD;
        ResultSrc  = 2'b01;
        PCWrite    = 1'b1;
        next_state = DECODE;
      end

      DECODE: begin
        ALUSrcA    = 2'b01;
        ALUSrcB    = 2'b01;
        ALUControl = ALU_ADD;
        ImmSrc     = 2'b10;

        case (opcode)
          OP_R_TYPE: next_state = R1;
          OP_I_TYPE, OP_JALR: next_state = I1;
          OP_LOAD: next_state = L1;
          OP_S_TYPE: next_state = S1;
          OP_B_TYPE: next_state = B1;
          OP_JAL: next_state = J1;
          default: next_state = FETCH;
        endcase
      end

      R1: begin
        ALUSrcA = 2'b10;
        ALUSrcB = 2'b00;
        case (func3)
          3'b000:  ALUControl = func7[5] ? ALU_SUB : ALU_ADD;
          3'b010:  ALUControl = ALU_SLT;
          3'b100:  ALUControl = ALU_XOR;
          3'b110:  ALUControl = ALU_OR;
          3'b111:  ALUControl = ALU_AND;
          default: ALUControl = ALU_ADD;
        endcase
        next_state = R2;
      end

      R2: begin
        ResultSrc  = 2'b00;
        RegWrite   = 1'b1;
        next_state = FETCH;
      end

      I1: begin
        ALUSrcA = 2'b10;
        ALUSrcB = 2'b01;
        ImmSrc  = 2'b00;
        case (opcode)
          OP_JALR: begin
            ALUSrcA = 2'b01;
            ALUSrcB = 2'b10;
            ALUControl = ALU_ADD;
          end
          default: begin
            case (func3)
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

      I2: begin
        case (opcode)
          OP_JALR: begin
            ResultSrc  = 2'b00;
            RegWrite   = 1'b1;
            next_state = I3;
          end
          default: begin
            ResultSrc  = 2'b00;
            RegWrite   = 1'b1;
            next_state = FETCH;
          end
        endcase
      end

      I3: begin
        PCWrite = 1'b1;
        ResultSrc = 2'b00;
        next_state = FETCH;
      end

      B1: begin
        ALUSrcA = 2'b10;
        ALUSrcB = 2'b00;
        ALUControl = ALU_SUB;
        ResultSrc = 2'b00;
        case (func3)
          3'b000:  PCWriteCond = zero;
          3'b001:  PCWriteCond = ~zero;
          3'b100:  PCWriteCond = sign;
          3'b101:  PCWriteCond = ~sign;
          default: PCWriteCond = 1'b0;
        endcase
        ResultSrc  = 2'b00;
        next_state = FETCH;
      end

      L1: begin
        ALUSrcA    = 2'b10;
        ALUSrcB    = 2'b01;
        ImmSrc     = 2'b00;
        ALUControl = ALU_ADD;
        next_state = L2;
      end

      L2: begin
        ResultSrc  = 2'b00;
        AdrSrc     = 1'b1;
        next_state = L3;
      end

      L3: begin
        ResultSrc  = 2'b10;
        RegWrite   = 1'b1;
        next_state = FETCH;
      end

      S1: begin
        ALUSrcA    = 2'b10;
        ALUSrcB    = 2'b01;
        ImmSrc     = 2'b01;
        ALUControl = ALU_ADD;
        next_state = S2;
      end

      S2: begin
        AdrSrc     = 1'b1;
        MemWrite   = 1'b1;
        ResultSrc  = 2'b00;
        next_state = FETCH;
      end

      J1: begin
        ALUSrcA    = 2'b01;
        ALUSrcB    = 2'b01;
        ALUControl = ALU_ADD;
        ImmSrc     = 2'b11;
        next_state = J2;
      end

      J2: begin
        ResultSrc  = 2'b11;
        RegWrite   = 1'b1;
        next_state = J3;
      end

      J3: begin
        PCWrite    = 1'b1;
        ResultSrc  = 2'b00;
        next_state = FETCH;
      end
      default: next_state = FETCH;
    endcase
  end
endmodule
