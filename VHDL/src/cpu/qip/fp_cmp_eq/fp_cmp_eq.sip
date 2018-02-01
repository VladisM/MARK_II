set_global_assignment -entity "fp_cmp_eq" -library "lib_fp_cmp_eq" -name IP_TOOL_NAME "altera_fp_functions"
set_global_assignment -entity "fp_cmp_eq" -library "lib_fp_cmp_eq" -name IP_TOOL_VERSION "17.0"
set_global_assignment -entity "fp_cmp_eq" -library "lib_fp_cmp_eq" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_fp_cmp_eq" -name SPD_FILE [file join $::quartus(sip_path) "fp_cmp_eq.spd"]

set_global_assignment -library "lib_fp_cmp_eq" -name MISC_FILE [file join $::quartus(sip_path) "fp_cmp_eq_sim/dspba_library_package.vhd"]
set_global_assignment -library "lib_fp_cmp_eq" -name MISC_FILE [file join $::quartus(sip_path) "fp_cmp_eq_sim/dspba_library.vhd"]
set_global_assignment -library "lib_fp_cmp_eq" -name MISC_FILE [file join $::quartus(sip_path) "fp_cmp_eq_sim/fp_cmp_eq.vhd"]
