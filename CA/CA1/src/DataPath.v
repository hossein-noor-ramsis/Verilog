module DataPath (
    input rst,
    clk,

    input [1:0] pc_src,
    input [1:0] result_src,
    input       mem_write,
    input [2:0] alu_control,
    input       alu_src,
    input [2:0] imm_src,
    input       reg_write,

    output zero_flag,
    sign_flag,

    output [6:0] opcode,
    output [2:0] funct3,
    output [6:0] funct7
);
  // PC signals
  wire [31:0] pc_next, pc_current, pc_plus4, pc_target;

  // Instruction signals
  wire [31:0] instruction;
  wire [4:0] rs1_addr, rs2_addr, rd_addr;
  wire [24:0] instruction_imm;

  // Register file signals
  wire [31:0] reg_read_data1, reg_read_data2, reg_write_data;

  // ALU signals
  wire signed [31:0] alu_operand_a, alu_operand_b;
  wire [31:0] alu_result, imm_extended;

  // Data memory signals
  wire [31:0] mem_read_data;

  // Instruction decoding
  assign opcode = instruction[6:0];
  assign funct3 = instruction[14:12];
  assign funct7 = instruction[31:25];
  assign rs1_addr = instruction[19:15];
  assign rs2_addr = instruction[24:20];
  assign rd_addr = instruction[11:7];
  assign instruction_imm = instruction[31:7];

  // Program Counter
  PC program_counter (
      .pc_next   (pc_next),
      .clk       (clk),
      .rst       (rst),
      .pc_current(pc_current)
  );

  // Instruction Memory
  InstMemory instruction_memory (
      .pc         (pc_current),
      .instruction(instruction)
  );

  // Register File
  RegisterFile register_file (
      .rs1_addr    (rs1_addr),
      .rs2_addr    (rs2_addr),
      .rd_addr     (rd_addr),
      .write_data  (reg_write_data),
      .write_enable(reg_write),
      .clk         (clk),
      .rs1_data    (reg_read_data1),
      .rs2_data    (reg_read_data2)
  );

  // ALU operand A (always from register)
  assign alu_operand_a = reg_read_data1;

  // Mux for ALU operand B (register or immediate)
  Mux2To1 alu_src_mux (
      .input_a(reg_read_data2),
      .input_b(imm_extended),
      .select(alu_src),
      .mux_output(alu_operand_b)
  );

  // ALU
  ALU alu_unit (
      .operand_a  (alu_operand_a),
      .operand_b  (alu_operand_b),
      .alu_control(alu_control),
      .zero_flag  (zero_flag),
      .sign_flag  (sign_flag),
      .alu_result (alu_result)
  );

  // Data Memory
  DataMemory data_memory (
      .address     (alu_result),
      .write_data  (reg_read_data2),
      .write_enable(mem_write),
      .clk         (clk),
      .read_data   (mem_read_data)
  );

  // Mux for result (write back to register file)
  Mux4To1 result_mux (
      .input_a(alu_result),
      .input_b(mem_read_data),
      .input_c(pc_plus4),
      .input_d(imm_extended),
      .select(result_src),
      .mux_output(reg_write_data)
  );

  // Mux for next PC value
  Mux3To1 pc_src_mux (
      .input_a(pc_plus4),
      .input_b(pc_target),
      .input_c(alu_result),
      .select(pc_src),
      .mux_output(pc_next)
  );

  // PC + 4 Adder
  Adder pc_plus4_adder (
      .operand_a   (pc_current),
      .operand_b   (32'd4),
      .adder_result(pc_plus4)
  );

  // PC Target Adder (for branches/JAL)
  Adder pc_target_adder (
      .operand_a   (pc_current),
      .operand_b   (imm_extended),
      .adder_result(pc_target)
  );

  // Immediate Extension
  ImmediateExt immediate_ext (
      .instruction (instruction_imm),
      .imm_src     (imm_src),
      .imm_extended(imm_extended)
  );

endmodule
