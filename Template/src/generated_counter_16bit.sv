module generated_counter_16bit (
    input logic        clk,
    input logic        arst,
    input logic        sys_ce,      // Primary System Count Enable
    inout logic [15:0] parallel_io
);

  // Array of wires to hold the carry-out signals between stages.
  // We need 4 signals: c[0] to c[3].
  logic c[3:0];

  // The 'generate' block is used for structural iteration
  generate
    for (genvar i = 0; i < 4; i++) begin : counter_stage

      // Determine the Count Enable (ce_in) for the current stage (i)
      // Stage 0 (i=0) gets the system's CE (sys_ce).
      // Stages 1-3 (i>0) get the carry-out from the previous stage (i-1).
      logic ce_in;
      if (i == 0) begin
        assign ce_in = sys_ce;
      end else begin
        // The current stage's CE is the previous stage's Carry-Out
        assign ce_in = c[i-1];
      end

      // Instantiate the 4-bit counter
      up_counter_4bit U (
          .clk        (clk),
          .arst       (arst),
          .ce         (ce_in),               // Count Enable calculated above
          // The current stage's Carry-Out goes into the wire array 'c'
          .carry_out  (c[i]),
          // Slice the 16-bit port into 4-bit segments: 0:3, 4:7, 8:11, 12:15
          .parallel_io(parallel_io[i*4+:4])
      );

    end
  endgenerate

endmodule
