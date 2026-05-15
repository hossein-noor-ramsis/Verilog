module Controller (
    input zero_flag,
    sign_flag,

    input [6:0] opcode,
    input [2:0] funct3,
    input [6:0] funct7,

    output reg [1:0] pc_src,
    output reg [1:0] result_src,
    output reg       mem_write,
    output reg [2:0] alu_control,
    output reg       alu_src,
    output reg [2:0] imm_src,
    output reg       reg_write
);
  always @(*) begin
    // Default values
    reg_write = 0;
    imm_src = 3'b000;
    alu_src = 0;
    mem_write = 0;
    result_src = 2'b00;
    pc_src = 2'b00;
    alu_control = 3'b000;

    case (opcode)
      // R-type
      7'b0110011: begin
        pc_src = 2'b00;
        result_src = 2'b00;
        mem_write = 0;
        alu_src = 0;
        imm_src = 3'b000;
        reg_write = 1;

        case ({
          funct7, funct3
        })
          {7'b0000000, 3'b000} : alu_control = 3'b010;  // ADD
          {7'b0100000, 3'b000} : alu_control = 3'b110;  // SUB
          {7'b0000000, 3'b010} : alu_control = 3'b111;  // SLT
          {7'b0000000, 3'b110} : alu_control = 3'b001;  // OR
          {7'b0000000, 3'b111} : alu_control = 3'b000;  // AND
          default: alu_control = 3'b000;  // Default to AND
        endcase
      end

      // I-type (ALU immediate)
      7'b0010011: begin
        pc_src = 2'b00;
        result_src = 2'b00;
        mem_write = 0;
        alu_src = 1;
        imm_src = 3'b000;
        reg_write = 1;

        case (funct3)
          3'b000:  alu_control = 3'b010;  // ADDI
          3'b010:  alu_control = 3'b111;  // SLTI
          3'b100:  alu_control = 3'b011;  // XORI
          3'b110:  alu_control = 3'b001;  // ORI
          default: alu_control = 3'b000;  // Default
        endcase
      end

      // Load
      7'b0000011: begin
        pc_src = 2'b00;
        result_src = 2'b01;
        mem_write = 0;
        alu_control = 3'b010;
        alu_src = 1;
        imm_src = 3'b000;
        reg_write = 1;
      end

      // Store
      7'b0100011: begin
        pc_src = 2'b00;
        result_src = 2'b00;
        mem_write = 1;
        alu_control = 3'b010;
        alu_src = 1;
        imm_src = 3'b001;
        reg_write = 0;
      end

      // Branch
      7'b1100011: begin
        pc_src = 2'b00;
        result_src = 2'b00;
        mem_write = 0;
        alu_control = 3'b110;
        alu_src = 0;
        imm_src = 3'b011;
        reg_write = 0;

        case (funct3)
          3'b000:  pc_src = zero_flag ? 2'b01 : 2'b00;  // BEQ
          3'b001:  pc_src = ~zero_flag ? 2'b01 : 2'b00;  // BNE
          3'b100:  pc_src = sign_flag ? 2'b01 : 2'b00;  // BLT
          3'b101:  pc_src = ~sign_flag ? 2'b01 : 2'b00;  // BGE
          default: pc_src = 2'b00;  // Default no branch
        endcase
      end

      // JAL
      7'b1101111: begin
        pc_src = 2'b01;
        result_src = 2'b10;
        mem_write = 0;
        alu_control = 3'b010;
        alu_src = 1;
        imm_src = 3'b010;
        reg_write = 1;
      end

      // JALR
      7'b1100111: begin
        pc_src = 2'b10;
        result_src = 2'b10;
        mem_write = 0;
        alu_control = 3'b010;
        alu_src = 1;
        imm_src = 3'b000;
        reg_write = 1;
      end
    endcase
  end
endmodule
