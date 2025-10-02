module adder #(
    parameter WIDTH = 8  // default width = 8 bits
) (
    input  [WIDTH-1:0] a,
    input  [WIDTH-1:0] b,
    output [WIDTH-1:0] sum
);
  assign sum = a + b;
endmodule

// module my_module #(
//     parameter WIDTH = 8,  // configurable constant
//     parameter DEPTH = 16
// ) (
//     input  wire             clk,      // ports
//     input  wire             rst,
//     input  wire [WIDTH-1:0] data_in,
//     output reg  [WIDTH-1:0] data_out
// );
//   // logic here
// endmodule

// module top;
//   reg [15:0] a, b;
//   wire [15:0] sum;

//   // Instantiate adder with WIDTH = 16
//   adder #(
//       .WIDTH(16)
//   ) my_adder (
//       .a  (a),
//       .b  (b),
//       .sum(sum)
//   );
// endmodule
