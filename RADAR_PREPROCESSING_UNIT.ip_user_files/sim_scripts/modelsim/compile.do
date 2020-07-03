vlib modelsim_lib/work
vlib modelsim_lib/msim

vlib modelsim_lib/msim/xil_defaultlib
vlib modelsim_lib/msim/xpm
vlib modelsim_lib/msim/fifo_generator_v13_2_4

vmap xil_defaultlib modelsim_lib/msim/xil_defaultlib
vmap xpm modelsim_lib/msim/xpm
vmap fifo_generator_v13_2_4 modelsim_lib/msim/fifo_generator_v13_2_4

vlog -work xil_defaultlib -64 -incr -sv "+incdir+../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/clk_wiz_0" \
"C:/Xilinx/Vivado/2019.1/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"C:/Xilinx/Vivado/2019.1/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm -64 -93 \
"C:/Xilinx/Vivado/2019.1/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work fifo_generator_v13_2_4 -64 -incr "+incdir+../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/clk_wiz_0" \
"../../ipstatic/simulation/fifo_generator_vlog_beh.v" \

vcom -work fifo_generator_v13_2_4 -64 -93 \
"../../ipstatic/hdl/fifo_generator_v13_2_rfs.vhd" \

vlog -work fifo_generator_v13_2_4 -64 -incr "+incdir+../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/clk_wiz_0" \
"../../ipstatic/hdl/fifo_generator_v13_2_rfs.v" \

vlog -work xil_defaultlib -64 -incr "+incdir+../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/clk_wiz_0" \
"../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/fifo_81_eth/sim/fifo_81_eth.v" \
"../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/fifo_50_eth/sim/fifo_50_eth.v" \
"../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/fifo_81_50/sim/fifo_81_50.v" \
"../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/fifo_ref_81/sim/fifo_ref_81.v" \
"../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/clk_wiz_0/clk_wiz_0_clk_wiz.v" \
"../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/clk_wiz_0/clk_wiz_0.v" \

vcom -work xil_defaultlib -64 -93 \
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

vlog -work xil_defaultlib \
"glbl.v"

