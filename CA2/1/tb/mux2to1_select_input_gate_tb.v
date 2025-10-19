`timescale 1ns / 1ns

module mux2to1_select_input_gate_tb ();
  reg a = 0, b = 0, s = 0, e = 0;
  wire y;

  // Instance
  mux2to1_select_input_gate uut (
      .a(a),
      .b(b),
      .s(s),
      .e(e),

      .y(y)
  );

  // Test Case
  initial begin
    a = 0;
    b = 0;
    s = 0;
    e = 0;
    #100;

    a = 1;
    b = 0;
    s = 0;
    e = 0;
    #100;

    a = 0;
    b = 1;
    s = 0;
    e = 0;
    #100;

    a = 1;
    b = 1;
    s = 0;
    e = 0;
    #100;

    a = 0;
    b = 0;
    s = 1;
    e = 0;
    #100;

    a = 1;
    b = 0;
    s = 1;
    e = 0;
    #100;

    a = 0;
    b = 1;
    s = 1;
    e = 0;
    #100;

    a = 1;
    b = 1;
    s = 1;
    e = 0;
    #100;

    a = 0;
    b = 0;
    s = 0;
    e = 1;
    #100;

    a = 1;
    b = 0;
    s = 0;
    e = 1;
    #100;

    a = 0;
    b = 1;
    s = 0;
    e = 1;
    #100;

    a = 1;
    b = 1;
    s = 0;
    e = 1;
    #100;

    a = 0;
    b = 0;
    s = 1;
    e = 1;
    #100;

    a = 1;
    b = 0;
    s = 1;
    e = 1;
    #100;

    a = 0;
    b = 1;
    s = 1;
    e = 1;
    #100;

    a = 1;
    b = 1;
    s = 1;
    e = 1;
    #100;

    $stop;
  end
endmodule
