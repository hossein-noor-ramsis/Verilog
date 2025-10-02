module adder_4bit (
    input  wire [3:0] a,
    b,
    output wire [4:0] sum
);
  assign sum = a + b;  // RTL style, high-level
endmodule
