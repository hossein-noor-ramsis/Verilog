module InstMemory (
    input  [31:0] A,
    output [31:0] RD
);
  reg [31:0] inst_mem[0:(2**10 - 1)];  // 1024 words of 32-bit = 4KB
  integer i;

  wire [9:0] word_index;
  assign word_index = A[11:2];
  // pc is 4x of word index so we shift it to the left by to to divide it to 4

  initial begin
    $readmemh("inst.mem", inst_mem);
  end

  assign RD = inst_mem[word_index];

  // //  Separate sensitivity lists for inputs and outputs
  // always @(A) begin
  //   $display("[%0t] InstMemory Input Change: A=0x%0h (word_index=%0d)", $time, A, word_index);
  // end

  // always @(RD) begin
  //   $display("[%0t] InstMemory Output Change: RD=0x%0h", $time, RD);
  // end
endmodule
