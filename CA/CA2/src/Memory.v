module Memory (
    input [31:0] addr,
    input [31:0] write_data,
    input        mem_write,
    input        clk,

    output [31:0] read_data
);
  reg [31:0] mem[0:(2**10 - 1)];  // 1K words = 4KB

  wire [9:0] word_index;
  assign word_index = addr[11:2];  // Byte addr to word index
  // pc is 4x of word index so we shift it to the left by to to divide it to 4

  initial begin
    $readmemh("memory.mem", mem);
  end

  always @(posedge clk) begin
    if (mem_write) mem[word_index] <= write_data;
  end

  assign read_data = mem[word_index];
endmodule
