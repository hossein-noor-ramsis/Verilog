module mealy_10110_post (
    input  logic clk,
    input  logic reset_n,
    input  logic serIn,
    output logic detOut
);

  typedef enum logic [2:0] {
    S0,
    S1,
    S2,
    S3,
    S4
  } state_t;

  state_t current_state, next_state;

  /* State Register */
  always_ff @(posedge clk or negedge reset_n) begin
    if (!reset_n) current_state <= S0;
    else current_state <= next_state;
  end

  /* Next-State + Output Logic */
  always_comb begin
    next_state = current_state;
    detOut = 0;

    case (current_state)
      S0: if (serIn) next_state = S1;

      S1:
      if (!serIn) next_state = S2;
      else next_state = S1;

      S2:
      if (serIn) next_state = S3;
      else next_state = S0;

      S3:
      if (serIn) next_state = S4;
      else next_state = S2;

      S4: begin
        if (!serIn) begin
          detOut     = 1;  // Mealy output
          next_state = S0;
        end else next_state = S1;
      end
    endcase
  end

endmodule
