`timescale 1ns / 1ns

module TB4 ();
  reg clk = 1'b0;
  reg rst = 1'b0;
  integer test_number;
  integer passed_tests;
  integer failed_tests;
  integer i;
  integer cycle_count;
  reg signed [31:0] actual_value;

  // Expected sorted array (ascending order)
  reg signed [31:0] expected[0:9];
  initial begin
    expected[0] = 1;
    expected[1] = 2;
    expected[2] = 3;
    expected[3] = 4;
    expected[4] = 5;
    expected[5] = 6;
    expected[6] = 7;
    expected[7] = 8;
    expected[8] = 9;
    expected[9] = 10;
  end

  // Control signals for monitoring
  wire mem_write;
  wire alu_src;
  wire reg_write;
  wire zero_flag;
  wire sign_flag;
  wire [1:0] pc_src;
  wire [1:0] result_src;
  wire [2:0] imm_src;
  wire [2:0] alu_control;
  wire [6:0] opcode;
  wire [2:0] funct3;
  wire [6:0] funct7;

  // Additional signals for debugging
  wire [31:0] pc_current;
  wire [31:0] instruction;
  wire [31:0] alu_result;
  wire [31:0] reg_write_data;
  wire [31:0] imm_extended;
  wire [31:0] reg_read_data1;
  wire [31:0] reg_read_data2;
  wire [4:0] rs1_addr;
  wire [4:0] rs2_addr;
  wire [4:0] rd_addr;

  // Instantiate RISC-V processor
  RISC_V risc_v (
      .clk(clk),
      .rst(rst)
  );

  // Connect to internal signals for monitoring
  assign mem_write = risc_v.controller.mem_write;
  assign alu_src = risc_v.controller.alu_src;
  assign reg_write = risc_v.controller.reg_write;
  assign zero_flag = risc_v.controller.zero_flag;
  assign sign_flag = risc_v.controller.sign_flag;
  assign pc_src = risc_v.controller.pc_src;
  assign result_src = risc_v.controller.result_src;
  assign imm_src = risc_v.controller.imm_src;
  assign alu_control = risc_v.controller.alu_control;
  assign opcode = risc_v.controller.opcode;
  assign funct3 = risc_v.controller.funct3;
  assign funct7 = risc_v.controller.funct7;

  assign pc_current = risc_v.datapath.program_counter.pc_current;
  assign instruction = risc_v.datapath.instruction;
  assign alu_result = risc_v.datapath.alu_unit.alu_result;
  assign reg_write_data = risc_v.datapath.reg_write_data;
  assign imm_extended = risc_v.datapath.imm_extended;
  assign reg_read_data1 = risc_v.datapath.reg_read_data1;
  assign reg_read_data2 = risc_v.datapath.reg_read_data2;
  assign rs1_addr = risc_v.datapath.rs1_addr;
  assign rs2_addr = risc_v.datapath.rs2_addr;
  assign rd_addr = risc_v.datapath.rd_addr;

  // Clock generation
  always #1 clk = ~clk;

  // Cycle counter
  always @(posedge clk or posedge rst) begin
    if (rst) cycle_count <= 0;
    else cycle_count <= cycle_count + 1;
  end

  // Function to decode instruction type
  function string decode_instruction;
    input [6:0] op;
    input [2:0] f3;
    input [6:0] f7;
    begin
      case (op)
        7'b0110011:  // R-type
        case ({
          f7, f3
        })
          {7'b0000000, 3'b000} : decode_instruction = "ADD";
          {7'b0100000, 3'b000} : decode_instruction = "SUB";
          {7'b0000000, 3'b001} : decode_instruction = "SLL";
          {7'b0000000, 3'b010} : decode_instruction = "SLT";
          {7'b0000000, 3'b011} : decode_instruction = "SLTU";
          {7'b0000000, 3'b100} : decode_instruction = "XOR";
          {7'b0000000, 3'b101} : decode_instruction = "SRL";
          {7'b0100000, 3'b101} : decode_instruction = "SRA";
          {7'b0000000, 3'b110} : decode_instruction = "OR";
          {7'b0000000, 3'b111} : decode_instruction = "AND";
          default: decode_instruction = "R-type?";
        endcase
        7'b0010011:  // I-type ALU
        case (f3)
          3'b000: decode_instruction = "ADDI";
          3'b010: decode_instruction = "SLTI";
          3'b011: decode_instruction = "SLTIU";
          3'b100: decode_instruction = "XORI";
          3'b110: decode_instruction = "ORI";
          3'b111: decode_instruction = "ANDI";
          3'b001: decode_instruction = "SLLI";
          3'b101:
          if (f7 == 7'b0000000) decode_instruction = "SRLI";
          else if (f7 == 7'b0100000) decode_instruction = "SRAI";
          else decode_instruction = "I-type?";
          default: decode_instruction = "I-type?";
        endcase
        7'b0000011:  // Load
        case (f3)
          3'b000:  decode_instruction = "LB";
          3'b001:  decode_instruction = "LH";
          3'b010:  decode_instruction = "LW";
          3'b100:  decode_instruction = "LBU";
          3'b101:  decode_instruction = "LHU";
          default: decode_instruction = "LOAD?";
        endcase
        7'b0100011:  // Store
        case (f3)
          3'b000:  decode_instruction = "SB";
          3'b001:  decode_instruction = "SH";
          3'b010:  decode_instruction = "SW";
          default: decode_instruction = "STORE?";
        endcase
        7'b1100011:  // Branch
        case (f3)
          3'b000:  decode_instruction = "BEQ";
          3'b001:  decode_instruction = "BNE";
          3'b100:  decode_instruction = "BLT";
          3'b101:  decode_instruction = "BGE";
          3'b110:  decode_instruction = "BLTU";
          3'b111:  decode_instruction = "BGEU";
          default: decode_instruction = "BRANCH?";
        endcase
        7'b1101111: decode_instruction = "JAL";
        7'b1100111: decode_instruction = "JALR";
        7'b0110111: decode_instruction = "LUI";
        7'b0010111: decode_instruction = "AUIPC";
        7'b0001111: decode_instruction = "FENCE";
        7'b1110011: decode_instruction = "ECALL/EBREAK";
        default: decode_instruction = "UNKNOWN";
      endcase
    end
  endfunction

  // Test sequence
  initial begin
    test_number  = 0;
    passed_tests = 0;
    failed_tests = 0;

    $display("========================================");
    $display("    RISC-V Sorting Test with Instruction Trace");
    $display("========================================");
    $display("");

    // Reset the processor
    $display("Resetting processor...");
    rst = 1'b1;
    #10;
    rst = 1'b0;
    $display("Reset completed");
    $display("");

    // Print initial array
    $display("Initial array:");
    for (i = 0; i < 10; i = i + 1) begin
      actual_value = risc_v.datapath.data_memory.data_mem[i];
      $display("  array[%0d] = %0d", i, actual_value);
    end

    $display("");
    $display("Executing...");
    $display("");

    // Print header for instruction trace
    $display(
        "----------------------------------------------------------------------------------------------------");
    $display(
        "Cycle | PC       | Instruction | Mnemonic   | rd | rs1| rs2| ALU Result | RegW | MemW | Branch");
    $display(
        "----------------------------------------------------------------------------------------------------");

    // Run program with instruction printing
    repeat (200) begin
      @(posedge clk);

      // Print instruction trace
      $display("%5d | %08h | %08h | %-10s | x%0d | x%0d | x%0d | %08h    |  %b   |  %b   |  %b",
               cycle_count, pc_current, instruction, decode_instruction(opcode, funct3, funct7),
               rd_addr, rs1_addr, rs2_addr, alu_result, reg_write, mem_write, (pc_src != 2'b00));
    end

    $display(
        "----------------------------------------------------------------------------------------------------");
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
        $display("    FAIL: Element %0d mismatch!", i);
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
    $display("Total Cycles: %0d", cycle_count);
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
