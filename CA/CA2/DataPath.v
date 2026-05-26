module DataPath (
    input logic clk,
    input logic pc_write,
    input logic pc_write_cond,
    input logic adr_src,
    input logic mem_write,
    input logic ir_write,
    input logic reg_write,
    input logic old_pc_write,

    input logic [1:0] result_src,
    input logic [1:0] alu_src_a,
    input logic [1:0] alu_src_b,

    input logic [2:0] alu_control,
    input logic [2:0] imm_src,

    output logic zero_flag,
    output logic sign_flag,

    output logic [6:0] funct7,
    output logic [2:0] funct3,
    output logic [6:0] opcode
);

  // ========================================================================
  // PC Signals
  // ========================================================================
  logic [31:0] pc_current;
  logic [31:0] pc_next;

  // ========================================================================
  // Instruction Register Signals
  // ========================================================================
  logic [31:0] instruction;
  logic [4:0] rs1_addr, rs2_addr, rd_addr;
  logic [24:0] instruction_imm;

  // ========================================================================
  // Register File Signals
  // ========================================================================
  logic [31:0] reg_read_data1, reg_read_data2, reg_write_data;

  // ========================================================================
  // ALU Signals
  // ========================================================================
  logic signed [31:0] alu_operand_a, alu_operand_b;
  logic [31:0] alu_result;
  logic [31:0] imm_extended;

  // ========================================================================
  // Data Memory Signals
  // ========================================================================
  logic [31:0] mem_read_data;

  // ========================================================================
  // Pipeline/Stage Registers
  // ========================================================================
  logic [31:0] result_reg;  // ALU result register (ALUOut)
  logic [31:0] address_reg;  // Memory address register
  logic [31:0] reg_b_reg;  // Register B output register (for store data)
  logic [31:0] mem_data_reg;  // Memory data register (MDR)
  logic [31:0] old_pc_reg;  // Old PC register (for JAL/JALR return)

  // ========================================================================
  // Control Logic Signals
  // ========================================================================
  logic        pc_write_qualified;  // Qualified PC write (conditional + unconditional)

  // ========================================================================
  // Instruction Decoding (Combinational)
  // ========================================================================
  assign opcode    = instruction[6:0];
  assign funct3    = instruction[14:12];
  assign funct7    = instruction[31:25];
  assign rs1_addr  = instruction[19:15];
  assign rs2_addr  = instruction[24:20];
  assign rd_addr   = instruction[11:7];
  assign instruction_imm = instruction[31:7];

  // ========================================================================
  // PC Write Logic (Branch condition)
  // ========================================================================
  assign pc_write_qualified = pc_write | (pc_write_cond & zero_flag);

  // ========================================================================
  // Multiplexers
  // ========================================================================
  logic [31:0] pc_mux_out;  // PC input mux
  logic [31:0] alu_a_mux_out;  // ALU A input mux
  logic [31:0] alu_b_mux_out;  // ALU B input mux
  logic [31:0] write_data_mux_out;  // Write-back data mux

  // ========================================================================
  // Instantiation: Program Counter
  // ========================================================================
  ProgramCounter program_counter (
      .clk       (clk),
      .write_en  (pc_write_qualified),
      .pc_next   (pc_next),
      .pc_current(pc_current)
  );

  // ========================================================================
  // Instantiation: Address Multiplexer (PC or ALU Result)
  // ========================================================================
  Mux2To1 address_mux (
      .input_a   (pc_current),
      .input_b   (result_reg),  // ALUOut for JALR
      .select    (adr_src),
      .mux_output(address_reg)
  );

  // ========================================================================
  // Instantiation: Data Memory
  // ========================================================================
  DataMemory data_memory (
      .address     (address_reg),
      .write_data  (reg_b_reg),     // Store data from register B
      .write_enable(mem_write),
      .clk         (clk),
      .read_data   (mem_read_data)
  );

  // ========================================================================
  // Instantiation: Old PC Register (for return address)
  // ========================================================================
  Reg_En old_pc_register (
      .clk     (clk),
      .load    (old_pc_write),
      .data_in (pc_current),
      .data_out(old_pc_reg)
  );

  // ========================================================================
  // Instantiation: Instruction Register
  // ========================================================================
  Reg_En instruction_register (
      .clk     (clk),
      .load    (ir_write),
      .data_in (mem_read_data),
      .data_out(instruction)
  );

  // ========================================================================
  // Instantiation: Memory Data Register
  // ========================================================================
  Reg mem_data_register (
      .clk     (clk),
      .data_in (mem_read_data),
      .data_out(mem_data_reg)
  );

  // ========================================================================
  // Instantiation: Register File
  // ========================================================================
  RegisterFile register_file (
      .clk         (clk),
      .write_enable(reg_write),
      .rs1_addr    (rs1_addr),
      .rs2_addr    (rs2_addr),
      .rd_addr     (rd_addr),
      .write_data  (reg_write_data),
      .rs1_data    (reg_read_data1),
      .rs2_data    (reg_read_data2)
  );

  // ========================================================================
  // Instantiation: Register A & B (for ALU inputs)
  // ========================================================================
  Reg register_a (
      .clk     (clk),
      .data_in (reg_read_data1),
      .data_out(alu_a_mux_out)
  );

  Reg register_b (
      .clk     (clk),
      .data_in (reg_read_data2),
      .data_out(reg_b_reg)
  );

  // ========================================================================
  // Instantiation: ALU A Source Multiplexer (3-to-1)
  // ========================================================================
  Mux3To1 alu_src_a_mux (
      .input_a   (pc_current),     // 00: PC
      .input_b   (old_pc_reg),     // 01: Old PC
      .input_c   (alu_a_mux_out),  // 10: Register A output
      .select    (alu_src_a),
      .mux_output(alu_operand_a)
  );

  // ========================================================================
  // Instantiation: ALU B Source Multiplexer (3-to-1)
  // ========================================================================
  Mux3To1 alu_src_b_mux (
      .input_a   (reg_b_reg),     // 00: Register B
      .input_b   (32'd4),         // 01: Constant 4
      .input_c   (imm_extended),  // 10: Immediate
      .select    (alu_src_b),
      .mux_output(alu_operand_b)
  );

  // ========================================================================
  // Instantiation: Immediate Extension Unit
  // ========================================================================
  ImmediateExtend immediate_extend (
      .instruction (instruction_imm),
      .imm_src     (imm_src),
      .imm_extended(imm_extended)
  );

  // ========================================================================
  // Instantiation: ALU
  // ========================================================================
  ALU alu_unit (
      .operand_a  (alu_operand_a),
      .operand_b  (alu_operand_b),
      .alu_control(alu_control),
      .zero_flag  (zero_flag),
      .sign_flag  (sign_flag),
      .alu_result (alu_result)
  );

  // ========================================================================
  // Instantiation: ALU Result Register
  // ========================================================================
  Reg alu_result_register (
      .clk     (clk),
      .data_in (alu_result),
      .data_out(result_reg)
  );

  // ========================================================================
  // Instantiation: Write-Back Multiplexer (4-to-1)
  // ========================================================================
  Mux4To1 write_back_mux (
      .input_a   (result_reg),     // 00: ALU result
      .input_b   (mem_data_reg),   // 01: Memory data
      .input_c   (pc_current),     // 10: PC+4 (for JAL)
      .input_d   (imm_extended),   // 11: Immediate (not used here)
      .select    (result_src),
      .mux_output(reg_write_data)
  );

  // ========================================================================
  // PC Next Logic (always PC+4 in this implementation)
  // ========================================================================
  assign pc_next = alu_result;  // ALU computes PC+4 or branch target

endmodule
