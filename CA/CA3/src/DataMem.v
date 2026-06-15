module DataMem (
    input clk,
    we,

    input [31:0] A,
    WD,

    output [31:0] ReadData
);
  reg [31:0] data_mem[0:(2**10 - 1)];  // 1K words = 4KB
  integer i;

  wire [9:0] word_index;
  assign word_index = A[11:2];  // Byte address to word index
  // pc is 4x of word index so we shift it to the left by to to divide it to 4

  initial begin
    $readmemh("data.mem", data_mem);
  end

  always @(posedge clk) begin
    if (we) data_mem[word_index] <= WD;
  end

  assign ReadData = data_mem[word_index];

  // //  Separate sensitivity lists for inputs and outputs
  // always @(A or WD or we) begin
  //   $display("[%0t] DataMem Input Change: A=0x%0h (word_index=%0d), WD=0x%0h (%0d), we=%0b", $time,
  //            A, word_index, WD, WD, we);
  // end

  // always @(ReadData) begin
  //   $display("[%0t] DataMem Output Change: ReadData=0x%0h (%0d)", $time, ReadData, ReadData);
  // end

  // // Log write operations on positive clock edge
  // always @(posedge clk) begin
  //   if (we) begin
  //     $display("[%0t] DataMem Write: Address=0x%0h (word_index=%0d), Data=0x%0h (%0d)", $time, A,
  //              word_index, WD, WD);
  //   end
  // end
endmodule
