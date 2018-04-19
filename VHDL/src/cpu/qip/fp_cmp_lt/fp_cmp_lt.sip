set_global_assignment -entity "fp_cmp_lt" -library "lib_fp_cmp_lt" -name IP_TOOL_NAME "altera_fp_functions"
set_global_assignment -entity "fp_cmp_lt" -library "lib_fp_cmp_lt" -name IP_TOOL_VERSION "17.0"
set_global_assignment -entity "fp_cmp_lt" -library "lib_fp_cmp_lt" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_fp_cmp_lt" -name SPD_FILE [file join $::quartus(sip_path) "fp_cmp_lt.spd"]

set_global_assignment -library "lib_fp_cmp_lt" -name MISC_FILE [file join $::quartus(sip_path) "fp_cmp_lt_sim/dspba_library_package.vhd"]
set_global_assignment -library "lib_fp_cmp_lt" -name MISC_FILE [file join $::quartus(sip_path) "fp_cmp_lt_sim/dspba_library.vhd"]
set_global_assignment -library "lib_fp_cmp_lt" -name MISC_FILE [file join $::quartus(sip_path) "fp_cmp_lt_sim/fp_cmp_lt.vhd"]
