set_global_assignment -entity "fp_div" -library "lib_fp_div" -name IP_TOOL_NAME "altera_fp_functions"
set_global_assignment -entity "fp_div" -library "lib_fp_div" -name IP_TOOL_VERSION "17.0"
set_global_assignment -entity "fp_div" -library "lib_fp_div" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_fp_div" -name SPD_FILE [file join $::quartus(sip_path) "fp_div.spd"]

set_global_assignment -library "lib_fp_div" -name MISC_FILE [file join $::quartus(sip_path) "fp_div_sim/fp_div_memoryC0_uid113_invTables_lutmem.hex"]
set_global_assignment -library "lib_fp_div" -name MISC_FILE [file join $::quartus(sip_path) "fp_div_sim/fp_div_memoryC1_uid116_invTables_lutmem.hex"]
set_global_assignment -library "lib_fp_div" -name MISC_FILE [file join $::quartus(sip_path) "fp_div_sim/fp_div_memoryC2_uid120_invTables_lutmem.hex"]
set_global_assignment -library "lib_fp_div" -name MISC_FILE [file join $::quartus(sip_path) "fp_div_sim/fp_div_memoryC1_uid117_invTables_lutmem.hex"]
set_global_assignment -library "lib_fp_div" -name MISC_FILE [file join $::quartus(sip_path) "fp_div_sim/fp_div_memoryC0_uid112_invTables_lutmem.hex"]
set_global_assignment -library "lib_fp_div" -name MISC_FILE [file join $::quartus(sip_path) "fp_div_sim/dspba_library_package.vhd"]
set_global_assignment -library "lib_fp_div" -name MISC_FILE [file join $::quartus(sip_path) "fp_div_sim/dspba_library.vhd"]
set_global_assignment -library "lib_fp_div" -name MISC_FILE [file join $::quartus(sip_path) "fp_div_sim/fp_div.vhd"]
