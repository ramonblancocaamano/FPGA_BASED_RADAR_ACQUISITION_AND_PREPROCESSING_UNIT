vlib questa_lib/work
vlib questa_lib/msim

vlib questa_lib/msim/fifo_generator_v13_2_4
vlib questa_lib/msim/xil_defaultlib

vmap fifo_generator_v13_2_4 questa_lib/msim/fifo_generator_v13_2_4
vmap xil_defaultlib questa_lib/msim/xil_defaultlib

vlog -work fifo_generator_v13_2_4 -64 \
"../../../ipstatic/simulation/fifo_generator_vlog_beh.v" \

vcom -work fifo_generator_v13_2_4 -64 -93 \
"../../../ipstatic/hdl/fifo_generator_v13_2_rfs.vhd" \

vlog -work fifo_generator_v13_2_4 -64 \
"../../../ipstatic/hdl/fifo_generator_v13_2_rfs.v" \

vlog -work xil_defaultlib -64 \
"../../../../RADAR_PREPROCESSING_UNIT.srcs/sources_1/ip/fifo_50_eth/sim/fifo_50_eth.v" \


vlog -work xil_defaultlib \
"glbl.v"

