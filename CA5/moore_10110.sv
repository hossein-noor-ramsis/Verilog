module moore_10110 (
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
    S4,
    S5
  } state_t;

  state_t current_state, next_state;

  /* State Register */
  always_ff @(posedge clk or negedge reset_n) begin
    if (!reset_n) current_state <= S0;
    else current_state <= next_state;
  end

  /* Next-State Logic */
  always_comb begin
    next_state = current_state;
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

      S4:
      if (!serIn) next_state = S5;
      else next_state = S1;

      S5: next_state = S0;
    endcase
  end

  /* Output Logic (Moore) */
  always_comb begin
    detOut = (current_state == S5);
  end

endmodule
