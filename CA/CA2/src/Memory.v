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

  initial begin
    $readmemh("memory.mem", mem);
    $display("Memory initialized from memory.mem");
  end

  always @(posedge clk) begin
    if (mem_write) begin
      mem[word_index] <= write_data;
      $display("Memory WRITE: addr=0x%08h, word_index=%0d, write_data=0x%08h, mem_write=%b", addr,
               word_index, write_data, mem_write);
    end
  end

  assign read_data = mem[word_index];

  // Log reads on any change
  always @(addr or mem_write) begin
    $display("Memory READ: addr=0x%08h, word_index=%0d, read_data=0x%08h, mem_write=%b", addr,
             word_index, mem[word_index], mem_write);
  end
endmodule
