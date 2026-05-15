module Adder (
    input signed [31:0] operand_a,
    operand_b,

    output signed [31:0] adder_result
);
  assign adder_result = operand_a + operand_b;
endmodule

module ALU (
    input signed [31:0] operand_a,
    operand_b,

    input [2:0] alu_control,

    output zero_flag,
    sign_flag,

    output reg signed [31:0] alu_result
);
  assign zero_flag = ~|alu_result;
  assign sign_flag = alu_result[31];

  always @(operand_a, operand_b, alu_control) begin
    case (alu_control)
      3'b000:  alu_result = operand_a & operand_b;  // AND
      3'b001:  alu_result = operand_a | operand_b;  // OR
      3'b010:  alu_result = operand_a + operand_b;  // ADD
      3'b110:  alu_result = operand_a - operand_b;  // SUB
      3'b011:  alu_result = operand_a ^ operand_b;  // XOR
      3'b111:  alu_result = (operand_a < operand_b) ? 1 : 0;  // SLT
      default: alu_result = 0;
    endcase
  end
endmodule

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
  always @(opcode, funct3, funct7, zero_flag, sign_flag) begin
    // Default values
    reg_write = 0;
    imm_src = 0;
    alu_src = 0;
    mem_write = 0;
    result_src = 0;
    pc_src = 0;
    alu_control = 0;

    case (opcode)
      // R-type
      7'b0110011: begin
        reg_write  = 1;
        result_src = 2'b00;

        case ({
          funct7, funct3
        })
          {7'b0000000, 3'b000} : alu_control = 3'b010;  // ADD
          {7'b0100000, 3'b000} : alu_control = 3'b110;  // SUB
          {7'b0000000, 3'b010} : alu_control = 3'b111;  // SLT
          {7'b0000000, 3'b110} : alu_control = 3'b001;  // OR
          {7'b0000000, 3'b111} : alu_control = 3'b000;  // AND
        endcase
      end

      // I-type (ALU immediate)
      7'b0010011: begin
        reg_write = 1;
        alu_src = 1;
        result_src = 2'b00;

        case (funct3)
          3'b000: alu_control = 3'b010;  // ADDI
          3'b010: alu_control = 3'b111;  // SLTI
          3'b100: alu_control = 3'b011;  // XORI
          3'b110: alu_control = 3'b001;  // ORI
        endcase
      end

      // Load
      7'b0000011: begin
        reg_write = 1;
        alu_src = 1;
        result_src = 2'b01;
        alu_control = 3'b010;  // ADD for address
      end

      // Store
      7'b0100011: begin
        mem_write = 1;
        alu_src = 1;
        imm_src = 3'b001;
        alu_control = 3'b010;  // ADD for address
      end

      // Branch
      7'b1100011: begin
        imm_src = 3'b010;
        alu_control = 3'b110;  // SUB for comparison

        case (funct3)
          3'b000: pc_src = zero_flag ? 2'b01 : 2'b00;  // BEQ
          3'b001: pc_src = ~zero_flag ? 2'b01 : 2'b00;  // BNE
          3'b100: pc_src = sign_flag ? 2'b01 : 2'b00;  // BLT
          3'b101: pc_src = (~sign_flag | zero_flag) ? 2'b01 : 2'b00;  // BGE
        endcase
      end

      // JAL
      7'b1101111: begin
        reg_write = 1;
        imm_src = 3'b011;
        result_src = 2'b10;
        pc_src = 2'b01;
        alu_control = 3'b010;
      end

      // JALR
      7'b1100111: begin
        reg_write = 1;
        alu_src = 1;
        result_src = 2'b10;
        pc_src = 2'b10;
        alu_control = 3'b010;
      end
    endcase
  end
endmodule

module DataMemory (
    input [31:0] address,
    write_data,
    input        write_enable,
    clk,

    output [31:0] read_data
);
  reg [31:0] data_mem[0:(2**10 - 1)];  // 1K words = 4KB
  integer i;

  wire [9:0] word_index;
  assign word_index = address[11:2];  // Byte address to word index

  initial begin
    for (i = 0; i < 2 ** 10; i = i + 1) begin
      data_mem[i] = 32'd0;
    end
    $readmemh("data.mem", data_mem);
  end

  always @(posedge clk) begin
    if (write_enable) data_mem[word_index] <= write_data;
  end

  assign read_data = data_mem[word_index];
endmodule

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
      .address    (pc_current),
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

module ImmediateExt (
    input [31:7] instruction,
    input [ 2:0] imm_src,

    output reg [31:0] imm_extended
);
  always @(instruction, imm_src) begin
    case (imm_src)
      // I-type
      3'b000: imm_extended = {{20{instruction[31]}}, instruction[31:20]};

      // S-type
      3'b001: imm_extended = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};

      // B-type
      3'b010:
      imm_extended = {
        {20{instruction[31]}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0
      };

      // J-type
      3'b011:
      imm_extended = {
        {11{instruction[31]}},
        instruction[31],
        instruction[19:12],
        instruction[20],
        instruction[30:21],
        1'b0
      };

      // U-type
      3'b100: imm_extended = {instruction[31:12], 12'd0};

      default: imm_extended = 32'd0;
    endcase
  end
endmodule


module InstMemory (
    input  [31:0] address,
    output [31:0] instruction
);
  reg [31:0] inst_mem[0:(2**10 - 1)];  // 1024 words of 32-bit = 4KB
  integer i;

  wire [9:0] word_index;
  assign word_index = address[11:2];

  initial begin
    for (i = 0; i < 2 ** 10; i = i + 1) begin
      inst_mem[i] = 32'd0;
    end
    $readmemh("inst.mem", inst_mem);
  end

  assign instruction = inst_mem[word_index];
endmodule

module Mux2To1 (
    input [31:0] input_a,
    input_b,

    input select,

    output [31:0] mux_output
);
  assign mux_output = select ? input_b : input_a;
endmodule

module Mux3To1 (
    input [31:0] input_a,
    input_b,
    input_c,

    input [1:0] select,

    output [31:0] mux_output
);
  assign mux_output = (select == 2'b00) ? input_a : (select == 2'b01) ? input_b : input_c;
endmodule

module Mux4To1 (
    input [31:0] input_a,
    input_b,
    input_c,
    input_d,

    input [1:0] select,

    output [31:0] mux_output
);
  assign mux_output = (select == 2'b00) ? input_a : 
                        (select == 2'b01) ? input_b : 
                        (select == 2'b10) ? input_c : 
                        input_d;
endmodule

module PC (
    input clk,
    rst,

    input [31:0] pc_next,

    output reg [31:0] pc_current
);
  always @(posedge clk) begin
    if (rst) pc_current <= 32'd0;
    else pc_current <= pc_next;
  end
endmodule

module RegisterFile (
    input clk,
    write_enable,

    input [4:0] rs1_addr,
    rs2_addr,
    rd_addr,

    input [31:0] write_data,

    output [31:0] rs1_data,
    rs2_data
);
  reg [31:0] reg_file[0:31];

  integer i;

  initial begin
    for (i = 0; i < 32; i = i + 1) begin
      reg_file[i] = 32'd0;
    end
  end

  // Read operations (combinational)
  assign rs1_data = (rs1_addr == 5'd0) ? 32'd0 : reg_file[rs1_addr];
  assign rs2_data = (rs2_addr == 5'd0) ? 32'd0 : reg_file[rs2_addr];

  // Write operation (sequential)
  always @(posedge clk) begin
    if (write_enable && (rd_addr != 5'd0)) reg_file[rd_addr] <= write_data;
  end
endmodule

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

`timescale 1ns / 1ns

module TestBench ();
  reg clk = 1'b0;
  reg rst = 1'b0;
  integer test_number;
  integer passed_tests;
  integer failed_tests;
  integer i;
  reg signed [31:0] actual_value;

  // Expected sorted array (ascending order)
  reg signed [31:0] expected[0:9];
  initial begin
    expected[0] = -99;
    expected[1] = -55;
    expected[2] = -12;
    expected[3] = -3;
    expected[4] = 0;
    expected[5] = 14;
    expected[6] = 23;
    expected[7] = 45;
    expected[8] = 67;
    expected[9] = 89;
  end

  // Instantiate RISC-V processor
  RISC_V risc_v (
      .clk(clk),
      .rst(rst)
  );

  // Clock generation
  always #1 clk = ~clk;

  // Test sequence
  initial begin
    test_number  = 0;
    passed_tests = 0;
    failed_tests = 0;

    $display("========================================");
    $display("    RISC-V Sorting Test");
    $display("========================================");
    $display("");

    // Reset the processor
    $display("Resetting processor...");
    rst = 1'b1;
    #10;
    rst = 1'b0;
    $display("Reset completed");
    $display("");

    // Debug: Show first 40 instructions
    // $display("First 40 instructions:");
    // repeat (40) begin
    //   @(negedge clk);
    //   $display("PC=%h Inst=%h RS1=%d RS2=%d RegWrite=%b MemWrite=%b Branch=%b",
    //            risc_v.datapath.program_counter.pc_current, risc_v.datapath.instruction,
    //            risc_v.datapath.rs1_addr, risc_v.datapath.rs2_addr, risc_v.datapath.reg_write,
    //            risc_v.datapath.mem_write, (risc_v.datapath.pc_src != 0));
    // end
    // $stop;

    // Print initial array
    $display("Initial array:");
    for (i = 0; i < 10; i = i + 1) begin
      actual_value = risc_v.datapath.data_memory.data_mem[i];

      $display("  array[%0d] = %0d", i, actual_value);
    end

    $display("");
    $display("Executing...");

    // Run program
    repeat (18) @(posedge clk);

    $display("");
    $display("Sorted array:");

    // Check sorted array
    for (i = 0; i < 10; i = i + 1) begin
      actual_value = risc_v.datapath.data_memory.data_mem[i];

      $display("  array[%0d] = %0d (expected %0d)", i, actual_value, expected[i]);

      if (actual_value == expected[i]) begin
        passed_tests = passed_tests + 1;
      end else begin
        failed_tests = failed_tests + 1;
        // $display("    FAIL: Element %0d mismatch!", i);
      end
    end

    // Final results
    $display("");
    $display("========================================");
    $display("    Test Results Summary");
    $display("========================================");
    $display("Array Elements Tested: 10");
    $display("Passed: %0d", passed_tests);
    $display("Failed: %0d", failed_tests);
    $display("========================================");

    if (failed_tests == 0) begin
      $display("ALL TESTS PASSED!");
    end else begin
      $display("SOME TESTS FAILED!");
    end

    $stop;
  end

  // Watchdog timer
  initial begin
    #10000;
    $display("");
    $display("TIMEOUT: Simulation stopped");
    $stop;
  end

endmodule
