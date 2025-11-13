`timescale 1ns / 1ns

module alu_behavioral_speed_tb;
  logic signed [15:0] inA, inB;
  logic inC;
  logic [2:0] opc;

  logic signed [15:0] outW1;
  logic zer1, neg1;

  logic signed [15:0] outW2;
  logic zer2, neg2;

  alu_behavioral dut1 (
      .inA(inA),
      .inB(inB),
      .inC(inC),
      .opc(opc),

      .outW(outW1),
      .zer (zer1),
      .neg (neg1)
  );

  alu_behavioral_netlist dut2 (
      .inA(inA),
      .inB(inB),
      .inC(inC),
      .opc(opc),

      .outW(outW2),
      .zer (zer2),
      .neg (neg2)
  );

  initial begin
    inA = 16'sd5;
    inB = 16'sd3;
    inC = 1'b0;
    opc = 3'b000;
    #20;

    inA = 16'sd9;
    inB = 16'sd3;
    inC = 1'b0;
    opc = 3'b000;
    #20;

    $stop;
  end

endmodule
