`timescale 1ns / 1ns

module and_gate (
    input  wire a,
    input  wire b,
    output wire y
);
  assign y = a & b;  // AND operation
endmodule
