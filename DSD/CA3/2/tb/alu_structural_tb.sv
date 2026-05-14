`timescale 1ns / 1ns

module alu_structural_tb;

  logic signed [15:0] inA, inB;
  logic inC;
  logic [2:0] opc;
  logic signed [15:0] outW;
  logic zer, neg;

  alu_structural dut (
      .inA(inA),
      .inB(inB),
      .inC(inC),
      .opc(opc),

      .outW(outW),
      .zer (zer),
      .neg (neg)
  );

  task print_result;
    $display("%6t |  %0d  | %8d | %8d |  %0d  | %8d |  %0d  |  %0d", $time, opc, inA, inB, inC,
             outW, zer, neg);
  endtask


  initial begin
    $display("  time | opc |      inA |      inB | Cin |     outW | zer | neg ");
    $display("----------------------------------------------------------------");

    inA = 16'sd5;
    inB = 16'sd3;
    inC = 1'b0;
    opc = 3'b000;
    #20;
    print_result();

    inA = 16'sd5;
    inB = 16'sd3;
    inC = 1'b0;
    opc = 3'b010;
    #20;
    print_result();

    inA = -16'sd7;
    inB = 16'sd2;
    inC = 1'b0;
    opc = 3'b011;
    #20;
    print_result();

    repeat (20) begin
      inA = $random;
      inB = $random;
      inC = $random & 1;
      opc = $random % 8;
      #20;
      print_result();
    end

    $finish;
  end

endmodule
