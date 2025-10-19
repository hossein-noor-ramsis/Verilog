`timescale 1ns / 1ns

module mux2to1_select_input_tristate_gate_tb2 ();
  reg a = 0, b = 0, s = 0, oe = 0;
  wire y1, y2;

  // Instance
  mux2to1_select_input_tristate_gate uut (
      .a (a),
      .b (b),
      .s (s),
      .oe(oe),

      .y(y1)
  );

  assign #(25, 21, 17) y2 = oe ? (a & ~s) | (b & s) : 1'bz;

  // Test Case
  initial begin
    a  = 0;
    b  = 0;
    s  = 0;
    oe = 0;
    #100;

    a  = 1;
    b  = 0;
    s  = 0;
    oe = 0;
    #100;

    a  = 0;
    b  = 1;
    s  = 0;
    oe = 0;
    #100;

    a  = 1;
    b  = 1;
    s  = 0;
    oe = 0;
    #100;

    a  = 0;
    b  = 0;
    s  = 1;
    oe = 0;
    #100;

    a  = 1;
    b  = 0;
    s  = 1;
    oe = 0;
    #100;

    a  = 0;
    b  = 1;
    s  = 1;
    oe = 0;
    #100;

    a  = 1;
    b  = 1;
    s  = 1;
    oe = 0;
    #100;

    a  = 0;
    b  = 0;
    s  = 0;
    oe = 1;
    #100;

    a  = 1;
    b  = 0;
    s  = 0;
    oe = 1;
    #100;

    a  = 0;
    b  = 1;
    s  = 0;
    oe = 1;
    #100;

    a  = 1;
    b  = 1;
    s  = 0;
    oe = 1;
    #100;

    a  = 0;
    b  = 0;
    s  = 1;
    oe = 1;
    #100;

    a  = 1;
    b  = 0;
    s  = 1;
    oe = 1;
    #100;

    a  = 0;
    b  = 1;
    s  = 1;
    oe = 1;
    #100;

    a  = 1;
    b  = 1;
    s  = 1;
    oe = 1;
    #100;

    $stop;
  end
endmodule
