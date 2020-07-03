-makelib xcelium_lib/xil_defaultlib -sv \
  "C:/Xilinx/Vivado/2019.1/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
  "C:/Xilinx/Vivado/2019.1/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \
-endlib
-makelib xcelium_lib/xpm \
  "C:/Xilinx/Vivado/2019.1/data/ip/xpm/xpm_VCOMP.vhd" \
-endlib
-makelib xcelium_lib/fifo_generator_v13_2_4 \
  "../../ipstatic/simulation/fifo_generator_vlog_beh.v" \
-endlib
-makelib xcelium_lib/fifo_generator_v13_2_4 \
  "../../ipstatic/hdl/fifo_generator_v13_2_rfs.vhd" \
-endlib
-makelib xcelium_lib/fifo_generator_v13_2_4 \
  "../../ipstatic/hdl/fifo_generator_v13_2_rfs.v" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/fifo_81_eth/sim/fifo_81_eth.v" \
  "../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/fifo_50_eth/sim/fifo_50_eth.v" \
  "../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/fifo_81_50/sim/fifo_81_50.v" \
  "../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/fifo_ref_81/sim/fifo_ref_81.v" \
  "../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/clk_wiz_0/clk_wiz_0_clk_wiz.v" \
  "../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/clk_wiz_0/clk_wiz_0.v" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/new/acquisition.vhd" \
  "../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/imports/hdl/add_crc32.vhd" \
  "../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/imports/hdl/add_preamble.vhd" \
  "../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/imports/hdl/add_seq_num.vhd" \
  "../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/new/control.vhd" \
  "../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/new/debouncer.vhd" \
  "../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/imports/hdl/ethernet.vhd" \
  "../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/new/ethernet_control.vhd" \
  "../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/new/interface.vhd" \
  "../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/new/memory.vhd" \
  "../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/new/mux2_16b.vhd" \
  "../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/imports/hdl/nibble_data.vhd" \
  "../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/new/processing.vhd" \
  "../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/new/resolution.vhd" \
  "../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/imports/new/sd.vhd" \
  "../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/new/sd_control.vhd" \
  "../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/new/main.vhd" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  glbl.v
-endlib

