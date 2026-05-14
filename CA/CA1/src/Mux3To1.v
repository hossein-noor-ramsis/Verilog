module Mux3To1 (
    input [31:0] input_a,
    input_b,
    input_c,

    input [1:0] select,

    output [31:0] mux_output
);
  assign mux_output = (select == 2'b00) ? input_a : (select == 2'b01) ? input_b : input_c;
endmodule
