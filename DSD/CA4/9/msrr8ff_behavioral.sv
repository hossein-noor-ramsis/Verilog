module msrr8ff_behavioral (
    input logic clk,
    input logic rst,  
    input logic inz,
    input logic [1:0] mode,
    input logic sIn,
    output logic [7:0] Q
);
  always_ff @(posedge clk or negedge rst) begin
    if (!rst) Q <= 8'b0; 
    else if (inz) Q <= 8'b0;  
    else begin
      case (mode)
        2'b00: Q <= Q;
        2'b01: Q <= {1'b0, Q[7:1]};  
        2'b10: Q <= {Q[0], Q[7:1]}; 
        2'b11: Q <= {sIn, sIn, Q[7:2]};
      endcase
    end
  end
endmodule
