`timescale 1ns / 1ns

module alu_behavioral (
    input logic signed [15:0] inA,
    input logic signed [15:0] inB,
    input logic               inC,
    input logic        [ 2:0] opc,  // operation code

    output logic signed [15:0] outW,
    output logic               zer,
    output logic               neg
);

  always @(inA, inB, inC, opc) begin
    outW = 16'b0;

    case (opc)
      3'b000:  outW = inA + inB + inC;
      3'b001:  outW = inA + 1;
      3'b010:  outW = (inA > inB) ? inA : inB;
      3'b011:  outW = inA + (inB >>> 1);
      3'b100:  outW = inA & inB;
      3'b101:  outW = inA | inB;
      3'b110:  outW = ~inA;
      3'b111:  outW = 16'b0;  // no operation
      default: outW = 16'b0;
    endcase

    zer = (outW == 16'b0);
    neg = outW[15];
  end
endmodule

// yosys command: yosys -p "read_verilog -sv alu_behavioral.sv; synth -top alu_behavioral; stat; write_verilog alu_behavioral_netlist.v"
// yosys command: yosys -p "read_verilog -sv alu_behavioral.sv; read_liberty mycells.lib; synth -top alu_behavioral; stat; write_verilog alu_behavioral_netlist.v" > yosys_report.txt
