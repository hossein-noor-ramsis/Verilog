`timescale 1ns / 1ns

module nand3_gate_tb;
  reg a = 0, b = 0, c = 0;
  wire w1, w2;

  // Instantiate
  nand3_gate uut (
      .a(a),
      .b(b),
      .c(c),
      .w(w1)
  );

  nand #(5, 12) (w2, a, b, c);

  // Test cases
  initial begin
    a = 0;
    b = 0;
    c = 0;
    #60;
    $display("a=%b b=%b c=%b w1=%b w2=%b", a, b, c, w1, w2);

    a = 1;
    b = 0;
    c = 0;
    #60;
    $display("a=%b b=%b c=%b w1=%b w2=%b", a, b, c, w1, w2);

    a = 0;
    b = 1;
    c = 0;
    #60;
    $display("a=%b b=%b c=%b w1=%b w2=%b", a, b, c, w1, w2);

    a = 1;
    b = 1;
    c = 0;
    #60;
    $display("a=%b b=%b c=%b w1=%b w2=%b", a, b, c, w1, w2);

    a = 0;
    b = 0;
    c = 1;
    #60;
    $display("a=%b b=%b c=%b w1=%b w2=%b", a, b, c, w1, w2);

    a = 1;
    b = 0;
    c = 1;
    #60;
    $display("a=%b b=%b c=%b w1=%b w2=%b", a, b, c, w1, w2);

    a = 0;
    b = 1;
    c = 1;
    #60;
    $display("a=%b b=%b c=%b w1=%b w2=%b", a, b, c, w1, w2);

    a = 1;
    b = 1;
    c = 1;
    #60;
    $display("a=%b b=%b c=%b w1=%b w2=%b", a, b, c, w1, w2);

    $stop;
  end
endmodule
