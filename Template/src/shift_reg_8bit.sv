module shift_reg_8bit (
    input  logic       clk,          // Falling-edge clock
    input  logic       reset,        // Asynchronous active-high reset
    input  logic       shift_en,     // Active-high shift enable
    input  logic       load_en,      // Active-high load enable
    input  logic       serial_in,    // Serial input (for right shift)
    input  logic [7:0] parallel_in,  // 8-bit parallel input
    output logic       serial_out,   // Serial output (bit 0)
    output logic [3:0] shift_out     // 4-bit shift output (bits 3:0)
);
  // Internal 8-bit register to hold the data
  logic [7:0] data_reg;

  // --- Core Sequential Logic ---
  // Uses an 'always_ff' block for sequential logic
  always_ff @(negedge clk or posedge reset) begin
    if (reset) begin
      // Asynchronous active-high reset: clear the register
      data_reg <= 8'b0;
    end else begin
      // Synchronous operations on the falling edge of the clock
      if (load_en) begin
        // Active-high load: P_IN takes precedence
        data_reg <= parallel_in;
      end else if (shift_en) begin
        // Active-high shift: Right shift
        // data_reg[7] gets serial_in
        // data_reg[6] gets data_reg[7], etc.
        data_reg <= {serial_in, data_reg[7:1]};
      end
      // else (no enable active): data_reg retains its current value (holds)
    end
  end

  // --- Output Assignments ---
  // Serial Output: Bit 0 of the register
  assign serial_out = data_reg[0];

  // 4-bit Shift Output: The lower 4 bits of the register (as required)
  assign shift_out  = data_reg[3:0];
endmodule
