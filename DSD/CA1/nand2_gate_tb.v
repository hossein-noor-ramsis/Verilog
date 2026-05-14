`timescale 1ns / 1ns

module nand2_gate_tb;
  reg a = 0, b = 0;
  wire w;

  // Instantiate
  nand2_gate uut (
      .a(a),
      .b(b),
      .w(w)
  );

  // Test cases
  initial begin
    a = 0;
    b = 0;
    #40;

    a = 0;
    b = 1;
    #40;

    a = 1;
    b = 0;
    #40;

    a = 1;
    b = 1;
    #40;

    $stop;
  end
endmodule

