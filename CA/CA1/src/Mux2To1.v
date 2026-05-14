module Mux2To1 (
    input [31:0] input_a,
    input_b,

    input select,

    output [31:0] mux_output
);
  assign mux_output = select ? input_b : input_a;
endmodule
