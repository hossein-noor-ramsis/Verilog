`timescale 1ns / 1ns

module alu_behavioral_speed_tb;
  logic signed [15:0] inA = 16'b0, inB = 16'b0;
  logic inC = 1'b0;
  logic [2:0] opc = 2'b0;

  logic signed [15:0] outW1 = 16'b0;
  logic zer1 = 1'b0, neg1 = 1'b0;

  logic signed [15:0] outW2 = 16'b0;
  logic zer2 = 1'b0, neg2 = 1'b0;

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
    #100;

    inA = 16'sd9;
    inB = 16'sd3;
    inC = 1'b0;
    opc = 3'b000;
    #100;

    $stop;
  end

endmodule
