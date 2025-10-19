`timescale 1ns / 1ns

module mux2to1_select_input_gate_tb3 ();
  reg a = 0, b = 0, s = 0, oe = 0;
  wire y1, y2;

  // Instance
  mux2to1_select_input_gate uut (
      .a(a),
      .b(b),
      .s(s),
      .e(oe),

      .y(y1)
  );

  assign #(25, 21, 17) y2 = oe ? (a & ~s) | (b & s) : 1'bz;

  // Test Case
  initial begin
    s  = 0;
    a  = 0;
    b  = 0;
    oe = 0;
    #200;

    s  = 1;
    a  = 0;
    b  = 0;
    oe = 0;
    #200;

    s  = 0;
    a  = 1;
    b  = 0;
    oe = 0;
    #200;

    s  = 1;
    a  = 1;
    b  = 0;
    oe = 0;
    #200;

    s  = 0;
    a  = 0;
    b  = 1;
    oe = 0;
    #200;

    s  = 1;
    a  = 0;
    b  = 1;
    oe = 0;
    #200;

    s  = 0;
    a  = 1;
    b  = 1;
    oe = 0;
    #200;

    s  = 1;
    a  = 1;
    b  = 1;
    oe = 0;
    #200;

    s  = 0;
    a  = 0;
    b  = 0;
    oe = 1;
    #200;

    s  = 1;
    a  = 0;
    b  = 0;
    oe = 1;
    #200;

    s  = 0;
    a  = 1;
    b  = 0;
    oe = 1;
    #200;

    s  = 1;
    a  = 1;
    b  = 0;
    oe = 1;
    #200;

    s  = 0;
    a  = 0;
    b  = 1;
    oe = 1;
    #200;

    s  = 1;
    a  = 0;
    b  = 1;
    oe = 1;
    #200;

    s  = 0;
    a  = 1;
    b  = 1;
    oe = 1;
    #200;

    s  = 1;
    a  = 1;
    b  = 1;
    oe = 1;
    #200;

    $stop;
  end
endmodule
