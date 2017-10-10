# Copyright (C) 1991-2013 Altera Corporation
# Your use of Altera Corporation's design tools, logic functions 
# and other software and tools, and its AMPP partner logic 
# functions, and any output files from any of the foregoing 
# (including device programming or simulation files), and any 
# associated documentation or information are expressly subject 
# to the terms and conditions of the Altera Program License 
# Subscription Agreement, Altera MegaCore Function License 
# Agreement, or other applicable license agreement, including, 
# without limitation, that your use is for the sole purpose of 
# programming logic devices manufactured by Altera and sold by 
# Altera or its authorized distributors.  Please refer to the 
# applicable agreement for further details.

# Quartus II: Generate Tcl File for Project
# File: MARK_II.tcl
# Generated on: Sat Sep 30 12:20:44 2017

# Load Quartus II Tcl Project package
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
    set_global_assignment -name FAMILY "Cyclone IV E"
    set_global_assignment -name DEVICE EP4CE22F17C6
    set_global_assignment -name ORIGINAL_QUARTUS_VERSION 13.0
    set_global_assignment -name PROJECT_CREATION_TIME_DATE "12:01:54  SEPTEMBER 30, 2017"
    set_global_assignment -name LAST_QUARTUS_VERSION 13.0
    set_global_assignment -name PROJECT_OUTPUT_DIRECTORY output_files
    set_global_assignment -name MIN_CORE_JUNCTION_TEMP 0
    set_global_assignment -name MAX_CORE_JUNCTION_TEMP 85
    set_global_assignment -name ERROR_CHECK_FREQUENCY_DIVISOR 1
    set_global_assignment -name EDA_SIMULATION_TOOL "ModelSim-Altera (VHDL)"
    set_global_assignment -name EDA_OUTPUT_DATA_FORMAT VHDL -section_id eda_simulation
    set_global_assignment -name USE_CONFIGURATION_DEVICE OFF
    set_global_assignment -name CRC_ERROR_OPEN_DRAIN OFF
    set_global_assignment -name RESERVE_ALL_UNUSED_PINS_WEAK_PULLUP "AS INPUT TRI-STATED"
    set_global_assignment -name STRATIX_DEVICE_IO_STANDARD "3.3-V LVTTL"
    set_global_assignment -name OUTPUT_IO_TIMING_NEAR_END_VMEAS "HALF VCCIO" -rise
    set_global_assignment -name OUTPUT_IO_TIMING_NEAR_END_VMEAS "HALF VCCIO" -fall
    set_global_assignment -name OUTPUT_IO_TIMING_FAR_END_VMEAS "HALF SIGNAL SWING" -rise
    set_global_assignment -name OUTPUT_IO_TIMING_FAR_END_VMEAS "HALF SIGNAL SWING" -fall
    set_global_assignment -name PARTITION_NETLIST_TYPE SOURCE -section_id Top
    set_global_assignment -name PARTITION_FITTER_PRESERVATION_LEVEL PLACEMENT_AND_ROUTING -section_id Top
    set_global_assignment -name PARTITION_COLOR 16764057 -section_id Top
    set_instance_assignment -name PARTITION_HIERARCHY root_partition -to | -section_id Top
    
    set_global_assignment -name VHDL_FILE ./src/cpu/cpu.vhd
    set_global_assignment -name VHDL_FILE ./src/cpu/id.vhd
    set_global_assignment -name VHDL_FILE ./src/gpio/gpio.vhd
    set_global_assignment -name VHDL_FILE ./src/interruptControl/intController.vhd
    set_global_assignment -name VHDL_FILE ./src/ps2/ps2core.vhd
    set_global_assignment -name VHDL_FILE ./src/ps2/ps2.vhd
    set_global_assignment -name VHDL_FILE ./src/ram/ram.vhd
    set_global_assignment -name VHDL_FILE ./src/systimer/systim.vhd
    set_global_assignment -name VHDL_FILE ./src/rom/rom.vhd
    set_global_assignment -name VHDL_FILE ./src/timer/timer.vhd
    set_global_assignment -name VHDL_FILE ./src/timer/core.vhd
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
    set_global_assignment -name VHDL_FILE ./src/sdram/reader.vhd
    set_global_assignment -name VHDL_FILE ./src/sdram/writer.vhd
    set_global_assignment -name VHDL_FILE ./src/sdram/bus_interface.vhd

    set_global_assignment -name VERILOG_FILE ./src/sdram/sdram_controller.v

    set_global_assignment -name QIP_FILE ./src/cpu/qip/add.qip
    set_global_assignment -name QIP_FILE ./src/cpu/qip/div.qip
    set_global_assignment -name QIP_FILE ./src/cpu/qip/fpcmp.qip
    set_global_assignment -name QIP_FILE ./src/cpu/qip/mul.qip
    set_global_assignment -name QIP_FILE ./src/clkgen/pll_peripherals.qip
    set_global_assignment -name QIP_FILE ./src/clkgen/pll_system.qip
    set_global_assignment -name QIP_FILE ./src/sdram/fifo/fifo.qip
    set_global_assignment -name QIP_FILE ./src/sdram/fifo/fifo_rd_addr.qip
    set_global_assignment -name QIP_FILE ./src/sdram/fifo/fifo_rd_data.qip
    
    set_global_assignment -name SDC_FILE MARK_II.sdc
        
    set_location_assignment PIN_P16 -to blue[1]
    set_location_assignment PIN_R16 -to blue[0]
    set_location_assignment PIN_R8 -to clk
    set_location_assignment PIN_N16 -to green[1]
    set_location_assignment PIN_P15 -to green[0]
    set_location_assignment PIN_L14 -to h_sync
    set_location_assignment PIN_L3 -to porta[7]
    set_location_assignment PIN_B1 -to porta[6]
    set_location_assignment PIN_F3 -to porta[5]
    set_location_assignment PIN_D1 -to porta[4]
    set_location_assignment PIN_A11 -to porta[3]
    set_location_assignment PIN_B13 -to porta[2]
    set_location_assignment PIN_A13 -to porta[1]
    set_location_assignment PIN_A15 -to porta[0]
    set_location_assignment PIN_A2 -to portb[7]
    set_location_assignment PIN_A3 -to portb[6]
    set_location_assignment PIN_B3 -to portb[5]
    set_location_assignment PIN_B4 -to portb[4]
    set_location_assignment PIN_A4 -to portb[3]
    set_location_assignment PIN_B5 -to portb[2]
    set_location_assignment PIN_A5 -to portb[1]
    set_location_assignment PIN_D5 -to portb[0]
    set_location_assignment PIN_L16 -to ps2clk
    set_location_assignment PIN_L15 -to ps2dat
    set_location_assignment PIN_N15 -to red[1]
    set_location_assignment PIN_R14 -to red[0]
    set_location_assignment PIN_J15 -to res
    set_location_assignment PIN_J13 -to rx0
    set_location_assignment PIN_N14 -to rx1
    set_location_assignment PIN_E10 -to rx2
    set_location_assignment PIN_B6 -to tim0_pwma
    set_location_assignment PIN_A6 -to tim0_pwmb
    set_location_assignment PIN_B7 -to tim1_pwma
    set_location_assignment PIN_D6 -to tim1_pwmb
    set_location_assignment PIN_A7 -to tim2_pwma
    set_location_assignment PIN_C6 -to tim2_pwmb
    set_location_assignment PIN_C8 -to tim3_pwma
    set_location_assignment PIN_E6 -to tim3_pwmb
    set_location_assignment PIN_J16 -to tx0
    set_location_assignment PIN_K15 -to tx1
    set_location_assignment PIN_E11 -to tx2
    set_location_assignment PIN_M10 -to v_sync    
    set_location_assignment PIN_M7 -to sdram_bank_addr[0]
    set_location_assignment PIN_M6 -to sdram_bank_addr[1]
    set_location_assignment PIN_R6 -to sdram_data_mask_low
    set_location_assignment PIN_T5 -to sdram_data_mask_high
    set_location_assignment PIN_L2 -to sdram_ras_n
    set_location_assignment PIN_L1 -to sdram_cas_n
    set_location_assignment PIN_L7 -to sdram_clock_enable
    set_location_assignment PIN_R4 -to sdram_clk
    set_location_assignment PIN_C2 -to sdram_we_n
    set_location_assignment PIN_P6 -to sdram_cs_n
    set_location_assignment PIN_G2 -to sdram_data[0]
    set_location_assignment PIN_G1 -to sdram_data[1]
    set_location_assignment PIN_L8 -to sdram_data[2]
    set_location_assignment PIN_K5 -to sdram_data[3]
    set_location_assignment PIN_K2 -to sdram_data[4]
    set_location_assignment PIN_J2 -to sdram_data[5]
    set_location_assignment PIN_J1 -to sdram_data[6]
    set_location_assignment PIN_R7 -to sdram_data[7]
    set_location_assignment PIN_T4 -to sdram_data[8]
    set_location_assignment PIN_T2 -to sdram_data[9]
    set_location_assignment PIN_T3 -to sdram_data[10]
    set_location_assignment PIN_R3 -to sdram_data[11]
    set_location_assignment PIN_R5 -to sdram_data[12]
    set_location_assignment PIN_P3 -to sdram_data[13]
    set_location_assignment PIN_N3 -to sdram_data[14]
    set_location_assignment PIN_K1 -to sdram_data[15]
    set_location_assignment PIN_P2 -to sdram_addr[0]
    set_location_assignment PIN_N5 -to sdram_addr[1]
    set_location_assignment PIN_N6 -to sdram_addr[2]
    set_location_assignment PIN_M8 -to sdram_addr[3]
    set_location_assignment PIN_P8 -to sdram_addr[4]
    set_location_assignment PIN_T7 -to sdram_addr[5]
    set_location_assignment PIN_N8 -to sdram_addr[6]
    set_location_assignment PIN_T6 -to sdram_addr[7]
    set_location_assignment PIN_R1 -to sdram_addr[8]
    set_location_assignment PIN_P1 -to sdram_addr[9]
    set_location_assignment PIN_N2 -to sdram_addr[10]
    set_location_assignment PIN_N1 -to sdram_addr[11]
    set_location_assignment PIN_L4 -to sdram_addr[12]
            
    set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to blue[1]
    set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to blue[0]
    set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to clk
    set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to green[1]
    set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to green[0]
    set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to h_sync
    set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to porta[7]
    set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to porta[6]
    set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to porta[5]
    set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to porta[4]
    set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to porta[3]
    set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to porta[2]
    set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to porta[1]
    set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to porta[0]
    set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to portb[7]
    set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to portb[6]
    set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to portb[5]
    set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to portb[4]
    set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to portb[3]
    set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to portb[2]
    set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to portb[1]
    set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to portb[0]
    set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to ps2clk
    set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to ps2dat
    set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to red[1]
    set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to red[0]
    set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to res
    set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to rx0
    set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to rx1
    set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to rx2
    set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to tim0_pwma
    set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to tim0_pwmb
    set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to tim1_pwma
    set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to tim1_pwmb
    set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to tim2_pwma
    set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to tim2_pwmb
    set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to tim3_pwma
    set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to tim3_pwmb
    set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to tx0
    set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to tx1
    set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to tx2
    set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to v_sync
    set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_bank_addr[0]
    set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_bank_addr[1]
    set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_data_mask_low
    set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_data_mask_high
    set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_ras_n
    set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_cas_n
    set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_clock_enable
    set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_clk
    set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_we_n
    set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_cs_n
    set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_data[0]
    set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_data[1]
    set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_data[2]
    set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_data[3]
    set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_data[4]
    set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_data[5]
    set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_data[6]
    set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_data[7]
    set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_data[8]
    set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_data[9]
    set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_data[10]
    set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_data[11]
    set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_data[12]
    set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_data[13]
    set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_data[14]
    set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_data[15]
    set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_addr[0]
    set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_addr[1]
    set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_addr[2]
    set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_addr[3]
    set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_addr[4]
    set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_addr[5]
    set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_addr[6]
    set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_addr[7]
    set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_addr[8]
    set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_addr[9]
    set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_addr[10]
    set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_addr[11]
    set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_addr[12]
        
    # Commit assignments
    export_assignments

    # Close project
    if {$need_to_close_project} {
        project_close
    }
}
