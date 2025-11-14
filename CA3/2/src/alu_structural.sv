`timescale 1ns / 1ns

module alu_structural (
    input logic signed [15:0] inA,
    input logic signed [15:0] inB,
    input logic               inC,
    input logic        [ 2:0] opc,

    output logic signed [15:0] outW,
    output logic               zer,
    output logic               neg
);
  logic [15:0] sum1_wire;
  logic        cout1_wire;

  logic [15:0] sum2_wire;
  logic        cout2_wire;

  logic [15:0] sum3_wire;
  logic        cout3_wire;

  logic [15:0] shiftedB;
  assign shiftedB = inB >>> 1;

  logic cary1 = 1'b1;
  logic zero = 16'b0;

  logic isEq, isGt;

  adder16_component add0 (
      .a(inA),
      .b(inB),
      .cin(inC),
      .sum(sum1_wire),
      .cout(cout1_wire)
  );

  adder16_component add1 (
      .a(inA),
      .b(cary1),
      .cin(zero),
      .sum(sum2_wire),
      .cout(cout2_wire)
  );

  adder16_component add2 (
      .a(inA),
      .b(shiftedB),
      .cin(inC),
      .sum(sum3_wire),
      .cout(cout3_wire)
  );

  comp16_component comp (
      .A(inA),
      .B(inB),

      .isEq(isEq),
      .isGt(isGt)
  );

  always @(*) begin
    outW = 16'b0;
    zer  = 1'b0;
    neg  = 1'b0;

    case (opc)
      3'b000:  outW = sum1_wire;
      3'b001:  outW = sum2_wire;
      3'b010:  outW = isGt ? inA : inB;
      3'b011:  outW = sum3_wire;
      3'b100:  outW = inA & inB;
      3'b101:  outW = inA | inB;
      3'b110:  outW = ~inA;
      3'b111:  outW = 16'b0;
      default: outW = 16'b0;
    endcase

    zer = (outW == 16'b0);
    neg = outW[15];
  end

endmodule

// yosys -p "read_verilog -sv alu_structural.sv; synth -top alu_structural; dfflibmap -liberty mycells.lib; abc -liberty mycells.lib; clean; stat; write_verilog -noattr alu_structural_netlist.v"

// yosys -p "read_verilog -sv alu_structural.sv comp16_component.sv comp_gate.sv adder16_component.sv full_adder_gate.sv; synth -top alu_structural; dfflibmap -liberty mycells.lib; abc -liberty mycells.lib; clean; stat; write_verilog -noattr alu_structural_netlist.v"
