# Copyright (C) 2017  Intel Corporation. All rights reserved.
# Your use of Intel Corporation's design tools, logic functions 
# and other software and tools, and its AMPP partner logic 
# functions, and any output files from any of the foregoing 
# (including device programming or simulation files), and any 
# associated documentation or information are expressly subject 
# to the terms and conditions of the Intel Program License 
# Subscription Agreement, the Intel Quartus Prime License Agreement,
# the Intel MegaCore Function License Agreement, or other 
# applicable license agreement, including, without limitation, 
# that your use is for the sole purpose of programming logic 
# devices manufactured by Intel and sold by Intel or its 
# authorized distributors.  Please refer to the applicable 
# agreement for further details.

# Quartus Prime: Generate Tcl File for Project
# File: MARK_II2.tcl
# Generated on: Wed Jan 31 20:27:36 2018

# Load Quartus Prime Tcl Project package
package require ::quartus::project

set need_to_close_project 0
set make_assignments 1

# Check that the right project is open
if {[is_project_open]} {
	if {[string compare $quartus(project) "MARK_II"]} {
		puts "Project MARK_II is not open"
		set make_assignments 0
	}
} else {
	# Only open if not already open
	if {[project_exists MARK_II]} {
		project_open -revision MARK_II MARK_II
	} else {
		project_new -revision MARK_II MARK_II
	}
	set need_to_close_project 1
}

# Make assignments
if {$make_assignments} {
	set_global_assignment -name FAMILY "MAX 10"
	set_global_assignment -name DEVICE 10M25SAE144C8G
	set_global_assignment -name ORIGINAL_QUARTUS_VERSION 17.0.0
	set_global_assignment -name PROJECT_CREATION_TIME_DATE "20:19:17  LEDEN 31, 2018"
	set_global_assignment -name LAST_QUARTUS_VERSION "17.0.0 Lite Edition"
	set_global_assignment -name PROJECT_OUTPUT_DIRECTORY output_files
	set_global_assignment -name MIN_CORE_JUNCTION_TEMP 0
	set_global_assignment -name MAX_CORE_JUNCTION_TEMP 85
	set_global_assignment -name DEVICE_FILTER_PACKAGE "ANY QFP"
	set_global_assignment -name DEVICE_FILTER_PIN_COUNT 144
	set_global_assignment -name ERROR_CHECK_FREQUENCY_DIVISOR 256
	set_global_assignment -name ENABLE_OCT_DONE OFF
	set_global_assignment -name EXTERNAL_FLASH_FALLBACK_ADDRESS 00000000
	set_global_assignment -name STRATIXV_CONFIGURATION_SCHEME "PASSIVE SERIAL"
	set_global_assignment -name USE_CONFIGURATION_DEVICE OFF
	set_global_assignment -name INTERNAL_FLASH_UPDATE_MODE "SINGLE IMAGE WITH ERAM"
	set_global_assignment -name CRC_ERROR_OPEN_DRAIN OFF
	set_global_assignment -name STRATIX_DEVICE_IO_STANDARD "3.3-V LVTTL"
	set_global_assignment -name OUTPUT_IO_TIMING_NEAR_END_VMEAS "HALF VCCIO" -rise
	set_global_assignment -name OUTPUT_IO_TIMING_NEAR_END_VMEAS "HALF VCCIO" -fall
	set_global_assignment -name OUTPUT_IO_TIMING_FAR_END_VMEAS "HALF SIGNAL SWING" -rise
	set_global_assignment -name OUTPUT_IO_TIMING_FAR_END_VMEAS "HALF SIGNAL SWING" -fall
	set_global_assignment -name POWER_PRESET_COOLING_SOLUTION "23 MM HEAT SINK WITH 200 LFPM AIRFLOW"
	set_global_assignment -name POWER_BOARD_THERMAL_MODEL "NONE (CONSERVATIVE)"
	set_global_assignment -name FLOW_ENABLE_POWER_ANALYZER ON
	set_global_assignment -name POWER_DEFAULT_INPUT_IO_TOGGLE_RATE "12.5 %"

	set_global_assignment -name VHDL_FILE ./src/cpu/cpu.vhd
	set_global_assignment -name VHDL_FILE ./src/cpu/id.vhd
	set_global_assignment -name VHDL_FILE ./src/interruptControl/intController.vhd
	set_global_assignment -name VHDL_FILE ./src/ps2/ps2core.vhd
	set_global_assignment -name VHDL_FILE ./src/ps2/ps2.vhd
	set_global_assignment -name VHDL_FILE ./src/ram/ram.vhd
	set_global_assignment -name VHDL_FILE ./src/systimer/systim.vhd
	set_global_assignment -name VHDL_FILE ./src/rom/rom.vhd
	set_global_assignment -name VHDL_FILE ./src/uart/uart_core.vhd
	set_global_assignment -name VHDL_FILE ./src/uart/uart.vhd
	set_global_assignment -name VHDL_FILE ./src/uart/transmitter.vhd
	set_global_assignment -name VHDL_FILE ./src/uart/reciever.vhd
	set_global_assignment -name VHDL_FILE ./src/uart/baudgen.vhd
	set_global_assignment -name VHDL_FILE ./src/vga/vram.vhd
	set_global_assignment -name VHDL_FILE ./src/vga/vga.vhd
	set_global_assignment -name VHDL_FILE ./src/vga/font.vhd
	set_global_assignment -name VHDL_FILE ./src/MARK_II.vhd
	set_global_assignment -name VHDL_FILE ./src/clkgen/clkgen.vhd
	set_global_assignment -name VHDL_FILE ./src/sdram/sdram.vhd
	set_global_assignment -name VHDL_FILE ./src/sdram/bus_interface.vhd
	set_global_assignment -name VHDL_FILE ./src/sdram/sdram_driver.vhd
	set_global_assignment -name VHDL_FILE ./src/timer/timer.vhd	

	set_global_assignment -name QIP_FILE ./src/clkgen/pll.qip

	set_global_assignment -name QIP_FILE ./src/cpu/qip/fp_mul/fp_mul.qip
	set_global_assignment -name SIP_FILE ./src/cpu/qip/fp_mul/fp_mul.sip
	set_global_assignment -name QIP_FILE ./src/cpu/qip/fp_div/fp_div.qip
	set_global_assignment -name SIP_FILE ./src/cpu/qip/fp_div/fp_div.sip
	set_global_assignment -name QIP_FILE ./src/cpu/qip/fp_addsub/fp_addsub.qip
	set_global_assignment -name SIP_FILE ./src/cpu/qip/fp_addsub/fp_addsub.sip
	set_global_assignment -name QIP_FILE src/cpu/qip/fp_cmp_eq/fp_cmp_eq.qip
	set_global_assignment -name SIP_FILE src/cpu/qip/fp_cmp_eq/fp_cmp_eq.sip
	set_global_assignment -name QIP_FILE src/cpu/qip/fp_cmp_gt/fp_cmp_gt.qip
	set_global_assignment -name SIP_FILE src/cpu/qip/fp_cmp_gt/fp_cmp_gt.sip
	set_global_assignment -name QIP_FILE src/cpu/qip/fp_cmp_lt/fp_cmp_lt.qip
	set_global_assignment -name SIP_FILE src/cpu/qip/fp_cmp_lt/fp_cmp_lt.sip

	set_global_assignment -name SDC_FILE MARK_II.sdc
        
	set_location_assignment PIN_141 -to uart1_rts
	set_location_assignment PIN_140 -to uart1_txd
	set_location_assignment PIN_135 -to uart1_dtr
	set_location_assignment PIN_127 -to uart1_dcd
	set_location_assignment PIN_130 -to uart1_dsr
	set_location_assignment PIN_131 -to uart1_rxd
	set_location_assignment PIN_132 -to uart1_cts
	set_location_assignment PIN_134 -to uart1_ri
	set_location_assignment PIN_120 -to vga_hs
	set_location_assignment PIN_119 -to vga_vs
	set_location_assignment PIN_113 -to vga_r[2]
	set_location_assignment PIN_114 -to vga_r[1]
	set_location_assignment PIN_118 -to vga_r[0]
	set_location_assignment PIN_110 -to vga_g[2]
	set_location_assignment PIN_111 -to vga_g[1]
	set_location_assignment PIN_112 -to vga_g[0]
	set_location_assignment PIN_105 -to vga_b[1]
	set_location_assignment PIN_106 -to vga_b[0]
	set_location_assignment PIN_124 -to kb_clk
	set_location_assignment PIN_123 -to kb_dat
	set_location_assignment PIN_121 -to ms_clk
	set_location_assignment PIN_122 -to ms_dat
	set_location_assignment PIN_81 -to uart0_rxd
	set_location_assignment PIN_80 -to uart0_txd
	set_location_assignment PIN_79 -to uart0_cbus[1]
	set_location_assignment PIN_78 -to uart0_cbus[0]
	set_location_assignment PIN_27 -to enc_int
	set_location_assignment PIN_21 -to enc_cs
	set_location_assignment PIN_24 -to enc_si
	set_location_assignment PIN_25 -to enc_so
	set_location_assignment PIN_22 -to enc_sck
	set_location_assignment PIN_10 -to i2s_bck
	set_location_assignment PIN_11 -to i2s_din
	set_location_assignment PIN_12 -to i2s_lrck
	set_location_assignment PIN_7 -to scl
	set_location_assignment PIN_6 -to sda
	set_location_assignment PIN_8 -to rtc_mfp
	set_location_assignment PIN_69 -to sd_dat[3]
	set_location_assignment PIN_66 -to sd_dat[2]
	set_location_assignment PIN_76 -to sd_dat[1]
	set_location_assignment PIN_75 -to sd_dat[0]
	set_location_assignment PIN_70 -to sd_cmd
	set_location_assignment PIN_74 -to sd_clk
	set_location_assignment PIN_13 -to flash_cs
	set_location_assignment PIN_17 -to flash_sck
	set_location_assignment PIN_14 -to flash_so
	set_location_assignment PIN_15 -to flash_si
	set_location_assignment PIN_38 -to sdram_a[12]
	set_location_assignment PIN_39 -to sdram_a[11]
	set_location_assignment PIN_60 -to sdram_a[10]
	set_location_assignment PIN_41 -to sdram_a[9]
	set_location_assignment PIN_43 -to sdram_a[8]
	set_location_assignment PIN_44 -to sdram_a[7]
	set_location_assignment PIN_45 -to sdram_a[6]
	set_location_assignment PIN_46 -to sdram_a[5]
	set_location_assignment PIN_47 -to sdram_a[4]
	set_location_assignment PIN_65 -to sdram_a[3]
	set_location_assignment PIN_64 -to sdram_a[2]
	set_location_assignment PIN_62 -to sdram_a[1]
	set_location_assignment PIN_61 -to sdram_a[0]
	set_location_assignment PIN_28 -to sdram_dq[7]
	set_location_assignment PIN_29 -to sdram_dq[6]
	set_location_assignment PIN_30 -to sdram_dq[5]
	set_location_assignment PIN_32 -to sdram_dq[4]
	set_location_assignment PIN_54 -to sdram_dq[3]
	set_location_assignment PIN_52 -to sdram_dq[2]
	set_location_assignment PIN_50 -to sdram_dq[1]
	set_location_assignment PIN_48 -to sdram_dq[0]
	set_location_assignment PIN_59 -to sdram_ba[1]
	set_location_assignment PIN_58 -to sdram_ba[0]
	set_location_assignment PIN_57 -to sdram_ras
	set_location_assignment PIN_56 -to sdram_cas
	set_location_assignment PIN_55 -to sdram_we
	set_location_assignment PIN_33 -to sdram_clk
	set_location_assignment PIN_87 -to ex_cmd[3]
	set_location_assignment PIN_92 -to ex_cmd[2]
	set_location_assignment PIN_98 -to ex_cmd[1]
	set_location_assignment PIN_99 -to ex_cmd[0]
	set_location_assignment PIN_97 -to ex_dq[7]
	set_location_assignment PIN_96 -to ex_dq[6]
	set_location_assignment PIN_93 -to ex_dq[5]
	set_location_assignment PIN_89 -to ex_dq[4]
	set_location_assignment PIN_88 -to ex_dq[3]
	set_location_assignment PIN_86 -to ex_dq[2]
	set_location_assignment PIN_85 -to ex_dq[1]
	set_location_assignment PIN_84 -to ex_dq[0]
	set_location_assignment PIN_26 -to clk_25M
	set_location_assignment PIN_91 -to clk_18M432
	set_location_assignment PIN_90 -to clk_22M5792
	set_location_assignment PIN_101 -to pwrmng_rx
	set_location_assignment PIN_102 -to pwrmng_tx
	set_location_assignment PIN_100 -to pwrmng_res
	set_location_assignment PIN_77 -to res

	# Commit assignments
	export_assignments

	# Close project
	if {$need_to_close_project} {
		project_close
	}
}
