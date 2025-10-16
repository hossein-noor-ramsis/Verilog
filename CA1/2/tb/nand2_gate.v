`timescale 1ns / 1ns

module nand2_gate_tb;
  reg a = 0, b = 0;
  wire w1, w2;

  // Instantiate
  nand2_gate uut (
      .a(a),
      .b(b),
      .w(w1)
  );

  nand #(5, 8) (w2, a, b);

  // Test cases
  initial begin
    a = 0;
    b = 0;
    #40;
    $display("a=%b b=%b w1=%b w2=%b", a, b, w1, w2);

    a = 0;
    b = 1;
    #40;
    $display("a=%b b=%b w1=%b w2=%b", a, b, w1, w2);

    a = 1;
    b = 0;
    #40;
    $display("a=%b b=%b w1=%b w2=%b", a, b, w1, w2);

    a = 1;
    b = 1;
    #40;
    $display("a=%b b=%b w1=%b w2=%b", a, b, w1, w2);

    $stop;
  end
endmodule
