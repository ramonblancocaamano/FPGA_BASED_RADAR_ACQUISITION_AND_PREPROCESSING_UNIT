vlib work
vlib riviera

vlib riviera/xil_defaultlib
vlib riviera/xpm

vmap xil_defaultlib riviera/xil_defaultlib
vmap xpm riviera/xpm

vlog -work xil_defaultlib  -sv2k12 \
"C:/Xilinx/Vivado/2019.1/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"C:/Xilinx/Vivado/2019.1/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm -93 \
"C:/Xilinx/Vivado/2019.1/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work xil_defaultlib  -v2k5 \
"../../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/mig_7series/mig_7series/user_design/rtl/axi/mig_7series_v4_2_axi_ctrl_addr_decode.v" \
"../../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/mig_7series/mig_7series/user_design/rtl/axi/mig_7series_v4_2_axi_ctrl_read.v" \
"../../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/mig_7series/mig_7series/user_design/rtl/axi/mig_7series_v4_2_axi_ctrl_reg.v" \
"../../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/mig_7series/mig_7series/user_design/rtl/axi/mig_7series_v4_2_axi_ctrl_reg_bank.v" \
"../../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/mig_7series/mig_7series/user_design/rtl/axi/mig_7series_v4_2_axi_ctrl_top.v" \
"../../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/mig_7series/mig_7series/user_design/rtl/axi/mig_7series_v4_2_axi_ctrl_write.v" \
"../../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/mig_7series/mig_7series/user_design/rtl/axi/mig_7series_v4_2_axi_mc.v" \
"../../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/mig_7series/mig_7series/user_design/rtl/axi/mig_7series_v4_2_axi_mc_ar_channel.v" \
"../../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/mig_7series/mig_7series/user_design/rtl/axi/mig_7series_v4_2_axi_mc_aw_channel.v" \
"../../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/mig_7series/mig_7series/user_design/rtl/axi/mig_7series_v4_2_axi_mc_b_channel.v" \
"../../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/mig_7series/mig_7series/user_design/rtl/axi/mig_7series_v4_2_axi_mc_cmd_arbiter.v" \
"../../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/mig_7series/mig_7series/user_design/rtl/axi/mig_7series_v4_2_axi_mc_cmd_fsm.v" \
"../../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/mig_7series/mig_7series/user_design/rtl/axi/mig_7series_v4_2_axi_mc_cmd_translator.v" \
"../../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/mig_7series/mig_7series/user_design/rtl/axi/mig_7series_v4_2_axi_mc_fifo.v" \
"../../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/mig_7series/mig_7series/user_design/rtl/axi/mig_7series_v4_2_axi_mc_incr_cmd.v" \
"../../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/mig_7series/mig_7series/user_design/rtl/axi/mig_7series_v4_2_axi_mc_r_channel.v" \
"../../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/mig_7series/mig_7series/user_design/rtl/axi/mig_7series_v4_2_axi_mc_simple_fifo.v" \
"../../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/mig_7series/mig_7series/user_design/rtl/axi/mig_7series_v4_2_axi_mc_wrap_cmd.v" \
"../../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/mig_7series/mig_7series/user_design/rtl/axi/mig_7series_v4_2_axi_mc_wr_cmd_fsm.v" \
"../../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/mig_7series/mig_7series/user_design/rtl/axi/mig_7series_v4_2_axi_mc_w_channel.v" \
"../../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/mig_7series/mig_7series/user_design/rtl/axi/mig_7series_v4_2_ddr_axic_register_slice.v" \
"../../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/mig_7series/mig_7series/user_design/rtl/axi/mig_7series_v4_2_ddr_axi_register_slice.v" \
"../../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/mig_7series/mig_7series/user_design/rtl/axi/mig_7series_v4_2_ddr_axi_upsizer.v" \
"../../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/mig_7series/mig_7series/user_design/rtl/axi/mig_7series_v4_2_ddr_a_upsizer.v" \
"../../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/mig_7series/mig_7series/user_design/rtl/axi/mig_7series_v4_2_ddr_carry_and.v" \
"../../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/mig_7series/mig_7series/user_design/rtl/axi/mig_7series_v4_2_ddr_carry_latch_and.v" \
"../../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/mig_7series/mig_7series/user_design/rtl/axi/mig_7series_v4_2_ddr_carry_latch_or.v" \
"../../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/mig_7series/mig_7series/user_design/rtl/axi/mig_7series_v4_2_ddr_carry_or.v" \
"../../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/mig_7series/mig_7series/user_design/rtl/axi/mig_7series_v4_2_ddr_command_fifo.v" \
"../../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/mig_7series/mig_7series/user_design/rtl/axi/mig_7series_v4_2_ddr_comparator.v" \
"../../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/mig_7series/mig_7series/user_design/rtl/axi/mig_7series_v4_2_ddr_comparator_sel.v" \
"../../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/mig_7series/mig_7series/user_design/rtl/axi/mig_7series_v4_2_ddr_comparator_sel_static.v" \
"../../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/mig_7series/mig_7series/user_design/rtl/axi/mig_7series_v4_2_ddr_r_upsizer.v" \
"../../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/mig_7series/mig_7series/user_design/rtl/axi/mig_7series_v4_2_ddr_w_upsizer.v" \
"../../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/mig_7series/mig_7series/user_design/rtl/clocking/mig_7series_v4_2_clk_ibuf.v" \
"../../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/mig_7series/mig_7series/user_design/rtl/clocking/mig_7series_v4_2_infrastructure.v" \
"../../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/mig_7series/mig_7series/user_design/rtl/clocking/mig_7series_v4_2_iodelay_ctrl.v" \
"../../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/mig_7series/mig_7series/user_design/rtl/clocking/mig_7series_v4_2_tempmon.v" \
"../../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/mig_7series/mig_7series/user_design/rtl/controller/mig_7series_v4_2_arb_mux.v" \
"../../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/mig_7series/mig_7series/user_design/rtl/controller/mig_7series_v4_2_arb_row_col.v" \
"../../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/mig_7series/mig_7series/user_design/rtl/controller/mig_7series_v4_2_arb_select.v" \
"../../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/mig_7series/mig_7series/user_design/rtl/controller/mig_7series_v4_2_bank_cntrl.v" \
"../../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/mig_7series/mig_7series/user_design/rtl/controller/mig_7series_v4_2_bank_common.v" \
"../../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/mig_7series/mig_7series/user_design/rtl/controller/mig_7series_v4_2_bank_compare.v" \
"../../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/mig_7series/mig_7series/user_design/rtl/controller/mig_7series_v4_2_bank_mach.v" \
"../../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/mig_7series/mig_7series/user_design/rtl/controller/mig_7series_v4_2_bank_queue.v" \
"../../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/mig_7series/mig_7series/user_design/rtl/controller/mig_7series_v4_2_bank_state.v" \
"../../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/mig_7series/mig_7series/user_design/rtl/controller/mig_7series_v4_2_col_mach.v" \
"../../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/mig_7series/mig_7series/user_design/rtl/controller/mig_7series_v4_2_mc.v" \
"../../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/mig_7series/mig_7series/user_design/rtl/controller/mig_7series_v4_2_rank_cntrl.v" \
"../../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/mig_7series/mig_7series/user_design/rtl/controller/mig_7series_v4_2_rank_common.v" \
"../../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/mig_7series/mig_7series/user_design/rtl/controller/mig_7series_v4_2_rank_mach.v" \
"../../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/mig_7series/mig_7series/user_design/rtl/controller/mig_7series_v4_2_round_robin_arb.v" \
"../../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/mig_7series/mig_7series/user_design/rtl/ecc/mig_7series_v4_2_ecc_buf.v" \
"../../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/mig_7series/mig_7series/user_design/rtl/ecc/mig_7series_v4_2_ecc_dec_fix.v" \
"../../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/mig_7series/mig_7series/user_design/rtl/ecc/mig_7series_v4_2_ecc_gen.v" \
"../../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/mig_7series/mig_7series/user_design/rtl/ecc/mig_7series_v4_2_ecc_merge_enc.v" \
"../../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/mig_7series/mig_7series/user_design/rtl/ecc/mig_7series_v4_2_fi_xor.v" \
"../../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/mig_7series/mig_7series/user_design/rtl/ip_top/mig_7series_v4_2_memc_ui_top_axi.v" \
"../../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/mig_7series/mig_7series/user_design/rtl/ip_top/mig_7series_v4_2_mem_intfc.v" \
"../../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/mig_7series/mig_7series/user_design/rtl/phy/mig_7series_v4_2_ddr_byte_group_io.v" \
"../../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/mig_7series/mig_7series/user_design/rtl/phy/mig_7series_v4_2_ddr_byte_lane.v" \
"../../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/mig_7series/mig_7series/user_design/rtl/phy/mig_7series_v4_2_ddr_calib_top.v" \
"../../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/mig_7series/mig_7series/user_design/rtl/phy/mig_7series_v4_2_ddr_if_post_fifo.v" \
"../../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/mig_7series/mig_7series/user_design/rtl/phy/mig_7series_v4_2_ddr_mc_phy.v" \
"../../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/mig_7series/mig_7series/user_design/rtl/phy/mig_7series_v4_2_ddr_mc_phy_wrapper.v" \
"../../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/mig_7series/mig_7series/user_design/rtl/phy/mig_7series_v4_2_ddr_of_pre_fifo.v" \
"../../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/mig_7series/mig_7series/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_4lanes.v" \
"../../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/mig_7series/mig_7series/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_ck_addr_cmd_delay.v" \
"../../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/mig_7series/mig_7series/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_dqs_found_cal.v" \
"../../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/mig_7series/mig_7series/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_dqs_found_cal_hr.v" \
"../../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/mig_7series/mig_7series/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_init.v" \
"../../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/mig_7series/mig_7series/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_ocd_cntlr.v" \
"../../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/mig_7series/mig_7series/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_ocd_data.v" \
"../../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/mig_7series/mig_7series/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_ocd_edge.v" \
"../../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/mig_7series/mig_7series/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_ocd_lim.v" \
"../../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/mig_7series/mig_7series/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_ocd_mux.v" \
"../../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/mig_7series/mig_7series/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_ocd_po_cntlr.v" \
"../../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/mig_7series/mig_7series/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_ocd_samp.v" \
"../../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/mig_7series/mig_7series/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_oclkdelay_cal.v" \
"../../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/mig_7series/mig_7series/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_prbs_rdlvl.v" \
"../../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/mig_7series/mig_7series/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_rdlvl.v" \
"../../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/mig_7series/mig_7series/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_tempmon.v" \
"../../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/mig_7series/mig_7series/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_top.v" \
"../../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/mig_7series/mig_7series/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_wrcal.v" \
"../../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/mig_7series/mig_7series/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_wrlvl.v" \
"../../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/mig_7series/mig_7series/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_wrlvl_off_delay.v" \
"../../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/mig_7series/mig_7series/user_design/rtl/phy/mig_7series_v4_2_ddr_prbs_gen.v" \
"../../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/mig_7series/mig_7series/user_design/rtl/phy/mig_7series_v4_2_ddr_skip_calib_tap.v" \
"../../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/mig_7series/mig_7series/user_design/rtl/phy/mig_7series_v4_2_poc_cc.v" \
"../../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/mig_7series/mig_7series/user_design/rtl/phy/mig_7series_v4_2_poc_edge_store.v" \
"../../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/mig_7series/mig_7series/user_design/rtl/phy/mig_7series_v4_2_poc_meta.v" \
"../../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/mig_7series/mig_7series/user_design/rtl/phy/mig_7series_v4_2_poc_pd.v" \
"../../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/mig_7series/mig_7series/user_design/rtl/phy/mig_7series_v4_2_poc_tap_base.v" \
"../../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/mig_7series/mig_7series/user_design/rtl/phy/mig_7series_v4_2_poc_top.v" \
"../../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/mig_7series/mig_7series/user_design/rtl/ui/mig_7series_v4_2_ui_cmd.v" \
"../../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/mig_7series/mig_7series/user_design/rtl/ui/mig_7series_v4_2_ui_rd_data.v" \
"../../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/mig_7series/mig_7series/user_design/rtl/ui/mig_7series_v4_2_ui_top.v" \
"../../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/mig_7series/mig_7series/user_design/rtl/ui/mig_7series_v4_2_ui_wr_data.v" \
"../../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/mig_7series/mig_7series/user_design/rtl/mig_7series_mig_sim.v" \
"../../../../FPGA_BASED_RADAR_ACQUISITION_AND_PREPROCESSING_UNIT.srcs/sources_1/ip/mig_7series/mig_7series/user_design/rtl/mig_7series.v" \

vlog -work xil_defaultlib \
"glbl.v"

