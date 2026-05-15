module InstMemory (
    input  [31:0] pc,
    output [31:0] instruction
);
  reg [31:0] inst_mem[0:(2**10 - 1)];  // 1024 words of 32-bit = 4KB
  integer i;

  wire [9:0] word_index;
  assign word_index = pc[11:2];
  // pc is 4x of word index so we shift it to the left by to to divide it to 4

  initial begin
    $readmemh("inst.mem", inst_mem);
  end

  assign instruction = inst_mem[word_index];
endmodule
