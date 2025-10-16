`timescale 1ns / 1ns

module nand2_gate_tb2;
  reg a = 0, b = 0;
  wire w1, w2;

  // Instantiate
  nand2_gate uut2 (
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

