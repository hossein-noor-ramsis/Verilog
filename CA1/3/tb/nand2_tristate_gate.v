`timescale 1ns / 1ns

module nand2_tristate_gate_tb;
  reg a = 0, b = 0, c = 0;
  wire w;

  // Instantiate
  nand2_tristate_gate uut (
      .a(a),
      .b(b),
      .c(c),
      .w(w)
  );

  // Test cases
  initial begin
    a = 0;
    b = 0;
    c = 0;
    #50;

    a = 1;
    b = 0;
    c = 0;
    #50;

    a = 0;
    b = 1;
    c = 0;
    #50;

    a = 1;
    b = 1;
    c = 0;
    #50;

    a = 0;
    b = 0;
    c = 1;
    #50;

    a = 1;
    b = 0;
    c = 1;
    #50;

    a = 0;
    b = 1;
    c = 1;
    #50;

    a = 1;
    b = 1;
    c = 1;
    #50;

  end
endmodule
