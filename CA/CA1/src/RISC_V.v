module RISC_V (
    input clk,
    rst
);
  // Control signals
  wire mem_write, alu_src, reg_write;
  wire zero_flag, sign_flag;

  wire [1:0] pc_src;
  wire [1:0] result_src;
  wire [2:0] imm_src;
  wire [2:0] alu_control;
  wire [6:0] opcode;
  wire [2:0] funct3;
  wire [6:0] funct7;

  // DataPath
  DataPath datapath (
      .rst(rst),
      .clk(clk),
      .pc_src(pc_src),
      .result_src(result_src),
      .mem_write(mem_write),
      .alu_control(alu_control),
      .alu_src(alu_src),
      .imm_src(imm_src),
      .reg_write(reg_write),
      .zero_flag(zero_flag),
      .sign_flag(sign_flag),
      .opcode(opcode),
      .funct3(funct3),
      .funct7(funct7)
  );

  // Controller
  Controller controller (
      .zero_flag(zero_flag),
      .sign_flag(sign_flag),
      .opcode(opcode),
      .funct3(funct3),
      .funct7(funct7),
      .pc_src(pc_src),
      .result_src(result_src),
      .mem_write(mem_write),
      .alu_control(alu_control),
      .alu_src(alu_src),
      .imm_src(imm_src),
      .reg_write(reg_write)
  );

endmodule

