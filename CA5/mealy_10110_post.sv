// Copyright (C) 2025  Altera Corporation. All rights reserved.
// Your use of Altera Corporation's design tools, logic functions 
// and other software and tools, and any partner logic 
// functions, and any output files from any of the foregoing 
// (including device programming or simulation files), and any 
// associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License 
// Subscription Agreement, the Altera Quartus Prime License Agreement,
// the Altera IP License Agreement, or other applicable license
// agreement, including, without limitation, that your use is for
// the sole purpose of programming logic devices manufactured by
// Altera and sold by Altera or its authorized distributors.  Please
// refer to the Altera Software License Subscription Agreements 
// on the Quartus Prime software download page.

// VENDOR "Altera"
// PROGRAM "Quartus Prime"
// VERSION "Version 25.1std.0 Build 1129 10/21/2025 SC Lite Edition"

// DATE "12/26/2025 21:06:14"

// 
// Device: Altera 5CGXFC7C7F23C8 Package FBGA484
// 

// 
// This Verilog file should be used for Questa Altera FPGA (Verilog) only
// 

`timescale 1ns / 1ns

module CA5 (
    clk,
    reset_n,
    serIn,
    moore_out,
    mealy_out
);
  input clk;
  input reset_n;
  input serIn;
  output moore_out;
  output mealy_out;

  // Design Ports Information
  // moore_out	=>  Location: PIN_Y10,	 I/O Standard: 2.5 V,	 Current Strength: Default
  // mealy_out	=>  Location: PIN_K21,	 I/O Standard: 2.5 V,	 Current Strength: Default
  // serIn	=>  Location: PIN_K22,	 I/O Standard: 2.5 V,	 Current Strength: Default
  // clk	=>  Location: PIN_M16,	 I/O Standard: 2.5 V,	 Current Strength: Default
  // reset_n	=>  Location: PIN_L19,	 I/O Standard: 2.5 V,	 Current Strength: Default


  wire gnd;
  wire vcc;
  wire unknown;

  assign gnd = 1'b0;
  assign vcc = 1'b1;
  assign unknown = 1'bx;

  tri1 devclrn;
  tri1 devpor;
  tri1 devoe;
  wire \~QUARTUS_CREATED_GND~I_combout ;
  wire \serIn~input_o ;
  wire \clk~input_o ;
  wire \clk~inputCLKENA0_outclk ;
  wire \u2|Selector1~0_combout ;
  wire \reset_n~input_o ;
  wire \u2|current_state.S1~q ;
  wire \u2|Selector2~0_combout ;
  wire \u2|current_state.S2~q ;
  wire \u2|Selector3~0_combout ;
  wire \u2|current_state.S3~q ;
  wire \u2|Selector4~0_combout ;
  wire \u2|current_state.S4~q ;
  wire \u2|detOut~0_combout ;


  // Location: IOOBUF_X34_Y0_N93
  cyclonev_io_obuf \moore_out~output (
      .i(gnd),
      .oe(vcc),
      .dynamicterminationcontrol(gnd),
      .seriesterminationcontrol(16'b0000000000000000),
      .parallelterminationcontrol(16'b0000000000000000),
      .devoe(devoe),
      .o(moore_out),
      .obar()
  );
  // synopsys translate_off
  defparam \moore_out~output .bus_hold = "false";
defparam \moore_out~output .open_drain_output = "false";
defparam \moore_out~output .shift_series_termination_control = "false";
  // synopsys translate_on

  // Location: IOOBUF_X89_Y38_N39
  cyclonev_io_obuf \mealy_out~output (
      .i(!\u2|detOut~0_combout ),
      .oe(vcc),
      .dynamicterminationcontrol(gnd),
      .seriesterminationcontrol(16'b0000000000000000),
      .parallelterminationcontrol(16'b0000000000000000),
      .devoe(devoe),
      .o(mealy_out),
      .obar()
  );
  // synopsys translate_off
  defparam \mealy_out~output .bus_hold = "false";
defparam \mealy_out~output .open_drain_output = "false";
defparam \mealy_out~output .shift_series_termination_control = "false";
  // synopsys translate_on

  // Location: IOIBUF_X89_Y38_N55
  cyclonev_io_ibuf \serIn~input (
      .i(serIn),
      .ibar(gnd),
      .dynamicterminationcontrol(gnd),
      .o(\serIn~input_o )
  );
  // synopsys translate_off
  defparam \serIn~input .bus_hold = "false"; defparam \serIn~input .simulate_z_as = "z";
  // synopsys translate_on

  // Location: IOIBUF_X89_Y35_N61
  cyclonev_io_ibuf \clk~input (
      .i(clk),
      .ibar(gnd),
      .dynamicterminationcontrol(gnd),
      .o(\clk~input_o )
  );
  // synopsys translate_off
  defparam \clk~input .bus_hold = "false"; defparam \clk~input .simulate_z_as = "z";
  // synopsys translate_on

  // Location: CLKCTRL_G9
  cyclonev_clkena \clk~inputCLKENA0 (
      .inclk(\clk~input_o ),
      .ena(vcc),
      .outclk(\clk~inputCLKENA0_outclk ),
      .enaout()
  );
  // synopsys translate_off
  defparam \clk~inputCLKENA0 .clock_type = "global clock";
defparam \clk~inputCLKENA0 .disable_mode = "low";
defparam \clk~inputCLKENA0 .ena_register_mode = "always enabled";
defparam \clk~inputCLKENA0 .ena_register_power_up = "high";
defparam \clk~inputCLKENA0 .test_syn = "high";
  // synopsys translate_on

  // Location: LABCELL_X88_Y38_N21
  cyclonev_lcell_comb \u2|Selector1~0 (
      // Equation(s):
      // \u2|Selector1~0_combout  = ( !\u2|current_state.S3~q  & ( (\serIn~input_o  & !\u2|current_state.S2~q ) ) )

      .dataa(!\serIn~input_o ),
      .datab(gnd),
      .datac(gnd),
      .datad(!\u2|current_state.S2~q ),
      .datae(gnd),
      .dataf(!\u2|current_state.S3~q ),
      .datag(gnd),
      .cin(gnd),
      .sharein(gnd),
      .combout(\u2|Selector1~0_combout ),
      .sumout(),
      .cout(),
      .shareout()
  );
  // synopsys translate_off
  defparam \u2|Selector1~0 .extended_lut = "off";
defparam \u2|Selector1~0 .lut_mask = 64'h5500550000000000;
defparam \u2|Selector1~0 .shared_arith = "off";
  // synopsys translate_on

  // Location: IOIBUF_X89_Y38_N4
  cyclonev_io_ibuf \reset_n~input (
      .i(reset_n),
      .ibar(gnd),
      .dynamicterminationcontrol(gnd),
      .o(\reset_n~input_o )
  );
  // synopsys translate_off
  defparam \reset_n~input .bus_hold = "false"; defparam \reset_n~input .simulate_z_as = "z";
  // synopsys translate_on

  // Location: FF_X88_Y38_N23
  dffeas \u2|current_state.S1 (
      .clk(\clk~inputCLKENA0_outclk ),
      .d(\u2|Selector1~0_combout ),
      .asdata(vcc),
      .clrn(\reset_n~input_o ),
      .aload(gnd),
      .sclr(gnd),
      .sload(gnd),
      .ena(vcc),
      .devclrn(devclrn),
      .devpor(devpor),
      .q(\u2|current_state.S1~q ),
      .prn(vcc)
  );
  // synopsys translate_off
  defparam \u2|current_state.S1 .is_wysiwyg = "true";
defparam \u2|current_state.S1 .power_up = "low";
  // synopsys translate_on

  // Location: LABCELL_X88_Y38_N36
  cyclonev_lcell_comb \u2|Selector2~0 (
      // Equation(s):
      // \u2|Selector2~0_combout  = ( \u2|current_state.S3~q  & ( !\serIn~input_o  ) ) # ( !\u2|current_state.S3~q  & ( (!\serIn~input_o  & \u2|current_state.S1~q ) ) )

      .dataa(!\serIn~input_o ),
      .datab(gnd),
      .datac(gnd),
      .datad(!\u2|current_state.S1~q ),
      .datae(gnd),
      .dataf(!\u2|current_state.S3~q ),
      .datag(gnd),
      .cin(gnd),
      .sharein(gnd),
      .combout(\u2|Selector2~0_combout ),
      .sumout(),
      .cout(),
      .shareout()
  );
  // synopsys translate_off
  defparam \u2|Selector2~0 .extended_lut = "off";
defparam \u2|Selector2~0 .lut_mask = 64'h00AA00AAAAAAAAAA;
defparam \u2|Selector2~0 .shared_arith = "off";
  // synopsys translate_on

  // Location: FF_X88_Y38_N38
  dffeas \u2|current_state.S2 (
      .clk(\clk~inputCLKENA0_outclk ),
      .d(\u2|Selector2~0_combout ),
      .asdata(vcc),
      .clrn(\reset_n~input_o ),
      .aload(gnd),
      .sclr(gnd),
      .sload(gnd),
      .ena(vcc),
      .devclrn(devclrn),
      .devpor(devpor),
      .q(\u2|current_state.S2~q ),
      .prn(vcc)
  );
  // synopsys translate_off
  defparam \u2|current_state.S2 .is_wysiwyg = "true";
defparam \u2|current_state.S2 .power_up = "low";
  // synopsys translate_on

  // Location: LABCELL_X88_Y38_N39
  cyclonev_lcell_comb \u2|Selector3~0 (
      // Equation(s):
      // \u2|Selector3~0_combout  = ( \u2|current_state.S2~q  & ( \serIn~input_o  ) )

      .dataa(!\serIn~input_o ),
      .datab(gnd),
      .datac(gnd),
      .datad(gnd),
      .datae(gnd),
      .dataf(!\u2|current_state.S2~q ),
      .datag(gnd),
      .cin(gnd),
      .sharein(gnd),
      .combout(\u2|Selector3~0_combout ),
      .sumout(),
      .cout(),
      .shareout()
  );
  // synopsys translate_off
  defparam \u2|Selector3~0 .extended_lut = "off";
defparam \u2|Selector3~0 .lut_mask = 64'h0000000055555555;
defparam \u2|Selector3~0 .shared_arith = "off";
  // synopsys translate_on

  // Location: FF_X88_Y38_N41
  dffeas \u2|current_state.S3 (
      .clk(\clk~inputCLKENA0_outclk ),
      .d(\u2|Selector3~0_combout ),
      .asdata(vcc),
      .clrn(\reset_n~input_o ),
      .aload(gnd),
      .sclr(gnd),
      .sload(gnd),
      .ena(vcc),
      .devclrn(devclrn),
      .devpor(devpor),
      .q(\u2|current_state.S3~q ),
      .prn(vcc)
  );
  // synopsys translate_off
  defparam \u2|current_state.S3 .is_wysiwyg = "true";
defparam \u2|current_state.S3 .power_up = "low";
  // synopsys translate_on

  // Location: LABCELL_X88_Y38_N18
  cyclonev_lcell_comb \u2|Selector4~0 (
      // Equation(s):
      // \u2|Selector4~0_combout  = ( \u2|current_state.S3~q  & ( \serIn~input_o  ) )

      .dataa(!\serIn~input_o ),
      .datab(gnd),
      .datac(gnd),
      .datad(gnd),
      .datae(gnd),
      .dataf(!\u2|current_state.S3~q ),
      .datag(gnd),
      .cin(gnd),
      .sharein(gnd),
      .combout(\u2|Selector4~0_combout ),
      .sumout(),
      .cout(),
      .shareout()
  );
  // synopsys translate_off
  defparam \u2|Selector4~0 .extended_lut = "off";
defparam \u2|Selector4~0 .lut_mask = 64'h0000000055555555;
defparam \u2|Selector4~0 .shared_arith = "off";
  // synopsys translate_on

  // Location: FF_X88_Y38_N20
  dffeas \u2|current_state.S4 (
      .clk(\clk~inputCLKENA0_outclk ),
      .d(\u2|Selector4~0_combout ),
      .asdata(vcc),
      .clrn(\reset_n~input_o ),
      .aload(gnd),
      .sclr(gnd),
      .sload(gnd),
      .ena(vcc),
      .devclrn(devclrn),
      .devpor(devpor),
      .q(\u2|current_state.S4~q ),
      .prn(vcc)
  );
  // synopsys translate_off
  defparam \u2|current_state.S4 .is_wysiwyg = "true";
defparam \u2|current_state.S4 .power_up = "low";
  // synopsys translate_on

  // Location: LABCELL_X88_Y38_N54
  cyclonev_lcell_comb \u2|detOut~0 (
      // Equation(s):
      // \u2|detOut~0_combout  = ( \serIn~input_o  & ( \u2|current_state.S4~q  ) ) # ( \serIn~input_o  & ( !\u2|current_state.S4~q  ) ) # ( !\serIn~input_o  & ( !\u2|current_state.S4~q  ) )

      .dataa(gnd),
      .datab(gnd),
      .datac(gnd),
      .datad(gnd),
      .datae(!\serIn~input_o ),
      .dataf(!\u2|current_state.S4~q ),
      .datag(gnd),
      .cin(gnd),
      .sharein(gnd),
      .combout(\u2|detOut~0_combout ),
      .sumout(),
      .cout(),
      .shareout()
  );
  // synopsys translate_off
  defparam \u2|detOut~0 .extended_lut = "off";
defparam \u2|detOut~0 .lut_mask = 64'hFFFFFFFF0000FFFF;
defparam \u2|detOut~0 .shared_arith = "off";
  // synopsys translate_on

  // Location: LABCELL_X57_Y23_N0
  cyclonev_lcell_comb \~QUARTUS_CREATED_GND~I (
      // Equation(s):

      .dataa(gnd),
      .datab(gnd),
      .datac(gnd),
      .datad(gnd),
      .datae(gnd),
      .dataf(gnd),
      .datag(gnd),
      .cin(gnd),
      .sharein(gnd),
      .combout(\~QUARTUS_CREATED_GND~I_combout ),
      .sumout(),
      .cout(),
      .shareout()
  );
  // synopsys translate_off
  defparam \~QUARTUS_CREATED_GND~I .extended_lut = "off";
defparam \~QUARTUS_CREATED_GND~I .lut_mask = 64'h0000000000000000;
defparam \~QUARTUS_CREATED_GND~I .shared_arith = "off";
  // synopsys translate_on

endmodule
