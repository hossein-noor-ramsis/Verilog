`timescale 1ns / 1ns

module alu_behavioral_netlist_tb;
  reg signed [15:0] inA, inB;
  reg inC;
  reg [2:0] opc;
  wire signed [15:0] outW;
  wire zer, neg;

  alu_behavioral_netlist dut (
      .inA(inA),
      .inB(inB),
      .inC(inC),
      .opc(opc),

      .outW(outW),
      .zer (zer),
      .neg (neg)
  );


  task print_result;

    $display("%5t |  %0d  | %8d | %8d |  %0d  | %8d |  %0d  |  %0d", $time, opc, inA, inB, inC,
             outW, zer, neg);

  endtask

  initial begin
    $display(" time | opc |      inA |      inB | Cin |     outW | zer | neg ");
    $display("---------------------------------------------------------------");

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
      opc = $random % 8;  // opcode از 0 تا 7
      #20;
      print_result();
    end

    $finish;
  end

endmodule
