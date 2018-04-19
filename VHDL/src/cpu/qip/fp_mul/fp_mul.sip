set_global_assignment -entity "fp_mul" -library "lib_fp_mul" -name IP_TOOL_NAME "altera_fp_functions"
set_global_assignment -entity "fp_mul" -library "lib_fp_mul" -name IP_TOOL_VERSION "17.0"
set_global_assignment -entity "fp_mul" -library "lib_fp_mul" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_fp_mul" -name SPD_FILE [file join $::quartus(sip_path) "fp_mul.spd"]

set_global_assignment -library "lib_fp_mul" -name MISC_FILE [file join $::quartus(sip_path) "fp_mul_sim/dspba_library_package.vhd"]
set_global_assignment -library "lib_fp_mul" -name MISC_FILE [file join $::quartus(sip_path) "fp_mul_sim/dspba_library.vhd"]
set_global_assignment -library "lib_fp_mul" -name MISC_FILE [file join $::quartus(sip_path) "fp_mul_sim/fp_mul.vhd"]
