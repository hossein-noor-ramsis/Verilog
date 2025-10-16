`timescale 1ns / 1ns

module nand2_tristate_gate_tb2;
  reg a = 0, b = 0, c = 0;
  wire w1, w2, h;

  // Instantiate
  nand2_tristate_gate uut (
      .a(a),
      .b(b),
      .c(c),

      .w(w1)
  );

  nand2_gate uut2 (
      .a(a),
      .b(b),
      .w(h)
  );

  bufif1 #(10, 13, 15) uut3 (w2, h, c);

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
