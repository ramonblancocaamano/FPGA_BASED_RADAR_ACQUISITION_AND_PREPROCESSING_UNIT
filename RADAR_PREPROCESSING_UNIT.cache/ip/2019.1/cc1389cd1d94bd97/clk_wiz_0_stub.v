// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.1 (win64) Build 2552052 Fri May 24 14:49:42 MDT 2019
// Date        : Fri Jan 17 00:45:43 2020
// Host        : DESKTOP-RAMON running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
//               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ clk_wiz_0_stub.v
// Design      : clk_wiz_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a35ticsg324-1L
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix(clkfb_in, clk_25, clk_50, clk_81, clk_200, 
  clkfb_out, reset, clk_in1)
/* synthesis syn_black_box black_box_pad_pin="clkfb_in,clk_25,clk_50,clk_81,clk_200,clkfb_out,reset,clk_in1" */;
  input clkfb_in;
  output clk_25;
  output clk_50;
  output clk_81;
  output clk_200;
  output clkfb_out;
  input reset;
  input clk_in1;
endmodule
