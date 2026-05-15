module DataMemory (
    input [31:0] address,
    write_data,
    input        write_enable,
    clk,

    output [31:0] read_data
);
  reg [31:0] data_mem[0:(2**10 - 1)];  // 1K words = 4KB
  integer i;

  wire [9:0] word_index;
  assign word_index = address[11:2];  // Byte address to word index
  // pc is 4x of word index so we shift it to the left by to to divide it to 4

  initial begin
    for (i = 0; i < 2 ** 10; i = i + 1) begin
      data_mem[i] = 32'd0;
    end
    $readmemh("data.mem", data_mem);
  end

  always @(posedge clk) begin
    if (write_enable) data_mem[word_index] <= write_data;
  end

  assign read_data = data_mem[word_index];
endmodule
