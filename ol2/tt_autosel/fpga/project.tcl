add_file -type verilog project.v
add_file -type verilog ../i2c_master.v
add_file -type verilog ../i2c_eeprom.v
add_file -type verilog ../tt_autosel.v
add_file -type verilog uart_tx.v
add_file -type cst project.cst
add_file -type sdc project.sdc
set_device GW2AR-LV18QN88C8/I7
set_option -synthesis_tool gowinsynthesis
set_option -output_base_name project
set_option -verilog_std sysv2017
set_option -top_module fpga_top
run all