`timescale 1ns / 1ns

module nand3_gate_tb;
  reg a = 0, b = 0, c = 0;
  wire w;

  // Instantiate
  nand3_gate uut (
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
    #60;

    a = 1;
    b = 0;
    c = 0;
    #60;

    a = 0;
    b = 1;
    c = 0;
    #60;

    a = 1;
    b = 1;
    c = 0;
    #60;

    a = 0;
    b = 0;
    c = 1;
    #60;

    a = 1;
    b = 0;
    c = 1;
    #60;

    a = 0;
    b = 1;
    c = 1;
    #60;

    a = 1;
    b = 1;
    c = 1;
    #60;

    a = 0;
    b = 0;
    c = 0;
    #60;

    $stop;
  end
endmodule
