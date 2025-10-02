`timescale 1ns / 1ns

// File: tb/and_gate.v
module tb_and_gate;
  reg a, b;  // inputs to the module
  wire y;  // output from the module

  // Instantiate your AND gate
  and_gate uut (
      .a(a),
      .b(b),
      .y(y)
  );

  // Generate waveform file (optional)
  initial begin
    $dumpfile("wave/and_gate.vcd");
    $dumpvars(0, tb_and_gate);
  end

  // Test cases
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

    $finish;  // end simulation
  end
endmodule

// Compile
// iverilog -o and_test tb_and_gate.v and_gate.v

// Run simulation
// vvp and_test
