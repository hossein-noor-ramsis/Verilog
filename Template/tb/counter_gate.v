`timescale 1ns / 1ns

// File: tb/and_gate.v
module and_gate_tb;
  reg a, b;  // inputs to the module
  wire y;  // output from the module

  reg clk = 0;  // initialize clock
  reg rstn = 1;
  reg [3:0] count = 1;

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

    a = 1'bx;
    b = 1;
    #10;
    $display("a=%b b=%b y=%b", a, b, y);

    a = 1'bz;
    b = 1;
    #10;
    $display("a=%b b=%b y=%b", a, b, y);

    $finish;  // end simulation
  end

  always begin
    #5 clk = ~clk;  // toggle every 5 time units
  end

  always @(posedge clk) begin
    count <= count + 1;  // non-blocking assignment
    $display("run count: %d", count);
  end

  always @(negedge rstn) begin
    count <= 1;
  end

  always @(*) begin
    if (count > 3) begin
      rstn = 0;
    end
  end

  // always @(y) begin
  //   count = count + 1;
  //   $display("run count: %d", count);
  // end

endmodule

// Compile
// iverilog -o and_test tb_and_gate.v and_gate.v

// Run simulation
// vvp and_test
