`timescale 1ns / 1ns

module mux2to1_select_input_tristate_gate_tb ();
  reg a = 0, b = 0, s = 0, oe = 0;
  wire y;

  // Instance
  mux2to1_select_input_tristate_gate uut (
      .a (a),
      .b (b),
      .s (s),
      .oe(oe),

      .y(y)
  );

  // Test Case
  initial begin
    s  = 0;
    a  = 0;
    b  = 0;
    oe = 0;
    #100;

    s  = 1;
    a  = 0;
    b  = 0;
    oe = 0;
    #100;

    s  = 0;
    a  = 1;
    b  = 0;
    oe = 0;
    #100;

    s  = 1;
    a  = 1;
    b  = 0;
    oe = 0;
    #100;

    s  = 0;
    a  = 0;
    b  = 1;
    oe = 0;
    #100;

    s  = 1;
    a  = 0;
    b  = 1;
    oe = 0;
    #100;

    s  = 0;
    a  = 1;
    b  = 1;
    oe = 0;
    #100;

    s  = 1;
    a  = 1;
    b  = 1;
    oe = 0;
    #100;

    s  = 0;
    a  = 0;
    b  = 0;
    oe = 1;
    #100;

    s  = 1;
    a  = 0;
    b  = 0;
    oe = 1;
    #100;

    s  = 0;
    a  = 1;
    b  = 0;
    oe = 1;
    #100;

    s  = 1;
    a  = 1;
    b  = 0;
    oe = 1;
    #100;

    s  = 0;
    a  = 0;
    b  = 1;
    oe = 1;
    #100;

    s  = 1;
    a  = 0;
    b  = 1;
    oe = 1;
    #100;

    s  = 0;
    a  = 1;
    b  = 1;
    oe = 1;
    #100;

    s  = 1;
    a  = 1;
    b  = 1;
    oe = 1;
    #100;

    $stop;
  end
endmodule
