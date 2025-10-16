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
    $display("a=%b b=%b w=%b", a, b, w);

    a = 0;
    b = 1;
    #40;
    $display("a=%b b=%b w=%b", a, b, w);

    a = 1;
    b = 0;
    #40;
    $display("a=%b b=%b w=%b", a, b, w);

    a = 1;
    b = 1;
    #40;
    $display("a=%b b=%b w=%b", a, b, w);

    $stop;
  end
endmodule
