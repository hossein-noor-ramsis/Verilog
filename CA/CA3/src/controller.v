`define R_Type 7'b0110011
`define I_Type 7'b0010011
`define LW 7'b0000011
`define Jalr 7'b1100111
`define S_Type 7'b0100011
`define J_Type 7'b1101111
`define B_Type 7'b1100011
`define U_Type 7'b0110111

`define Add 10'b0000_0000_00
`define Sub 10'b0100_0000_00
`define And 10'b0000_0001_11
`define Or 10'b0000_0001_10
`define Slt 10'b0000_0000_10

`define lw 3'b010
`define addi 3'b000
`define xori 3'b100
`define ori 3'b110
`define slti 3'b010
`define jalr 3'b000

`define beq 3'b000
`define bne 3'b001
`define blt 3'b100
`define bge 3'b101

module Controller (
    input [2:0] func3,
    input [6:0] func7,
    op,
    output reg MemWrite,
    ALUSrc,
    RegWrite,
    Jump,
    Branch,
    Jalr,
    output reg [1:0] ResultSrc,
    output reg [2:0] ALUControl,
    ImmSrc
);
  wire [9:0] func;
  assign func = {func7, func3};
  always @(func3, func7, op) begin
    // Default values
    MemWrite   = 1'b0;
    ALUSrc     = 1'b0;
    RegWrite   = 1'b0;
    Jump       = 1'b0;
    Branch     = 1'b0;
    Jalr       = 1'b0;
    ResultSrc  = 2'b00;
    ALUControl = 3'b010;
    ImmSrc     = 3'b000;

    case (op)
      `R_Type: begin
        RegWrite = 1'b1;
        case (func)
          `Add: ALUControl = 3'b010;
          `Sub: ALUControl = 3'b110;
          `And: ALUControl = 3'b000;
          `Or:  ALUControl = 3'b001;
          `Slt: ALUControl = 3'b100;
        endcase
      end

      `LW: {RegWrite, ResultSrc, ALUSrc} = 4'b1011;

      `I_Type: begin
        {ALUSrc, RegWrite} = 2'b11;
        case (func3)
          `addi: ALUControl = 3'b010;
          `xori: ALUControl = 3'b011;
          `ori:  ALUControl = 3'b001;
          `slti: ALUControl = 3'b100;
        endcase
      end

      `Jalr: {Jalr, ALUSrc, ResultSrc, RegWrite} = 5'b11101;

      `S_Type: {ImmSrc, ALUSrc, MemWrite} = 5'b00111;

      `J_Type: {ResultSrc, ImmSrc, RegWrite, Jump} = 7'b1001111;

      `B_Type: begin
        {Branch, ImmSrc} = 4'b1010;
        case (func3)
          `beq: ALUControl = 3'b110;
          `bne: ALUControl = 3'b110;
          `blt: ALUControl = 3'b100;
          `bge: ALUControl = 3'b100;
        endcase
      end
    endcase
  end

  // //  Separate sensitivity lists for inputs and outputs
  // always @(func3 or func7 or op) begin
  //   $display("[%0t] Controller Input Change: op=%0b, func3=%0b, func7=%0b, func=%0b", $time, op,
  //            func3, func7, func);
  // end

  // always @(MemWrite or ALUSrc or RegWrite or Jump or Branch or Jalr or ResultSrc or ALUControl or ImmSrc) begin
  //   $display(
  //       "[%0t] Controller Output Change: MemWrite=%0b, ALUSrc=%0b, RegWrite=%0b, Jump=%0b, Branch=%0b, Jalr=%0b, ResultSrc=%0b, ALUControl=%0b, ImmSrc=%0b",
  //       $time, MemWrite, ALUSrc, RegWrite, Jump, Branch, Jalr, ResultSrc, ALUControl, ImmSrc);
  // end
endmodule
