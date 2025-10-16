`timescale 1ns / 1ns

module logic_tb;
  reg a, b;
  wire y_and, y_or;

  and_gate uut1 (
      .a(a),
      .b(b),
      .y(y_and)
  );

  or_gate uut2 (
      .a(a),
      .b(b),
      .y(y_or)
  );

  initial begin
    $dumpfile("wave/tb_logic.vcd");
    $dumpvars(0, tb_logic);

    a = 0;
    b = 0;
    #10;
    $display("a=%b b=%b y_and=%b y_or=%b", a, b, y_and, y_or);

    a = 0;
    b = 1;
    #10;
    $display("a=%b b=%b y_and=%b y_or=%b", a, b, y_and, y_or);

    a = 1;
    b = 0;
    #10;
    $display("a=%b b=%b y_and=%b y_or=%b", a, b, y_and, y_or);

    a = 1;
    b = 1;
    #10;
    $display("a=%b b=%b y_and=%b y_or=%b", a, b, y_and, y_or);

    $finish;
  end
endmodule
