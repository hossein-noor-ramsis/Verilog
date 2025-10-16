`timescale 1ns / 1ns

// File: tb/or_gate.v
module or_gate_tb;

  // Inputs
  reg  a;
  reg  b;

  // Output
  wire y;

  // Instantiate the OR gate
  or_gate uut (
      .a(a),
      .b(b),
      .y(y)
  );

  // Generate waveform file
  initial begin
    $dumpfile("wave/or_gate.vcd");
    $dumpvars(0, tb_or_gate);
  end

  // Apply test vectors
  initial begin
    a = 0;
    b = 0;
    #10;
    $display("a=%b b=%b y=%b", a, b, y);

    a = 0;
    b = 1;
    #10;
    $display("a=%b b=%b y=%b", a, b, y);

    a = 1;
    b = 0;
    #10;
    $display("a=%b b=%b y=%b", a, b, y);

    a = 1;
    b = 1;
    #10;
    $display("a=%b b=%b y=%b", a, b, y);

    $finish;
  end

endmodule
