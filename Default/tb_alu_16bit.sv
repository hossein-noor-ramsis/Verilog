// File: tb_alu_16bit.sv
module tb_alu_16bit;
  logic [15:0] a, b;
  logic [ 2:0] op;
  logic [15:0] result;

  // Instantiate ALU
  alu_16bit uut (
      .a(a),
      .b(b),
      .op(op),
      .result(result)
  );

  // Waveform generation
  initial begin
    $dumpfile("alu_wave.vcd");
    $dumpvars(0, tb_alu_16bit);
  end

  // Apply test cases
  initial begin
    a  = 16'h0001;
    b  = 16'h0001;
    op = 3'b000;
    #10;
    $display("ADD: %h", result);
    a  = 16'h0005;
    b  = 16'h0003;
    op = 3'b001;
    #10;
    $display("SUB: %h", result);
    a  = 16'h0F0F;
    b  = 16'h00FF;
    op = 3'b010;
    #10;
    $display("AND: %h", result);
    a  = 16'h0F0F;
    b  = 16'h00FF;
    op = 3'b011;
    #10;
    $display("OR: %h", result);
    a  = 16'hAAAA;
    b  = 16'h5555;
    op = 3'b100;
    #10;
    $display("XOR: %h", result);
    $finish;
  end
endmodule
