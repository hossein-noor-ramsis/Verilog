`timescale 1ns / 1ns

module native_mux2to1_select_input_gate (
    output wire y,

    input wire a,
    input wire b,
    input wire s,
    input wire e
);

  assign #(20, 20) y = e ? (a & ~s) | (b & s) : 1'b0;
endmodule
