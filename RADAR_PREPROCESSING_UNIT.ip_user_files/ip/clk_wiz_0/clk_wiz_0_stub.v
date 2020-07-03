// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.1 (win64) Build 2552052 Fri May 24 14:49:42 MDT 2019
// Date        : Fri Jan 17 19:04:05 2020
// Host        : DESKTOP-RAMON running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               C:/Users/ramon/Documents/GITHUB/RADAR_PREPROCESSING_UNIT/RADAR_PREPROCESSING_UNIT.srcs/sources_1/ip/clk_wiz_0/clk_wiz_0_stub.v
// Design      : clk_wiz_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a35ticsg324-1L
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module clk_wiz_0(clk_81, clk_200, clk_25, clk_50, reset, clk_in1)
/* synthesis syn_black_box black_box_pad_pin="clk_81,clk_200,clk_25,clk_50,reset,clk_in1" */;
  output clk_81;
  output clk_200;
  output clk_25;
  output clk_50;
  input reset;
  input clk_in1;
endmodule
