// 4-bit comparator with conditional operations
module comparator_4bit (
    output E,
    G,
    input [3:0] A,
    B
);

  // Using conditional operations for comparison
  assign E = (A == B) ? 1'b1 : 1'b0;
  assign G = (A > B) ? 1'b1 : 1'b0;

endmodule

// yosys -p "read_verilog -sv comparator_4bit.sv; synth -top comparator_4bit; stat; write_verilog comparator_4bit_netlist.v"
