`timescale 1ns / 1ns

module native_mux2to1_select_input_tristate_gate (
    output wire y,

    input wire a,
    input wire b,
    input wire s,
    input wire oe
);

  assign #(20, 20, 7) y = oe ? (a & ~s) | (b & s) : 1'bz;
endmodule
