#
# TT top level STA
#


# Segment signals
# ---------------

# Port: Control inputs
set all_ctl [list]
for {set i 0} {$i < 6} {incr i} {
	set j [expr $i+0]
	lappend all_ctl [ get_ports "pad_raw[$j]" ]
}

# Port: User IO
set all_pads_in  [list]
set all_pads_out [list]

	# UIO
for {set i 0} {$i < 8} {incr i} {
	set j [expr $i+32]
	lappend all_pads_in  [ get_ports "pad_raw[$j]" ]
	lappend all_pads_out [ get_ports "pad_raw[$j]" ]
}

	# UO
for {set i 0} {$i < 8} {incr i} {
	set j [expr $i+8]
	lappend all_pads_out [ get_ports "pad_raw[$j]" ]
}

	# UI
for {set i 0} {$i < 10} {incr i} {
	set j [expr $i+40]
	lappend all_pads_in  [ get_ports "pad_raw[$j]" ]
}

# Pins: User modules
set all_pins_um_ctl [ get_pins "*.tt_um_I/buf_ctl*/A" ]
set all_pins_um_iw  [ get_pins "*.tt_um_I/buf_in*/A" ]
set all_pins_um_ow  [ get_pins "*.tt_um_I/buf_out*/X" ]


# Inputs
# ------

# xxx
set_driving_cell -lib_cell sg13g2_buf_4 -pin X [all_inputs]


# Loads
# -----

# All `io_out` & `io_oeb` go to gpio_control_block and have a bit
# of capacitance (estimates from lib and gpio_control_block.spef)
set_load 0.03 [all_outputs]


# Assumptions
# -----------

# We assume the pull are disabled since it messes with the analysis
# (STA can't "see" that those are only active when disabled)
set_case_analysis one [get_pins *.mux_I/*bus_pull_ow_I*/TE_B]
set_case_analysis one [get_pins *.ctrl_I/*tbuf_spine_ow_I*/TE_B]


# Clock
# -----

# Only clock is the ctrl_sel_inc
# The internal sub-divided clocks are checked internally when
# hardening tt_ctrl itself so don't bother here
create_clock -name ctrl_inc -period 10 [ get_ports "pad_raw[1]" ]


# Max delays
# ----------

# No artifical delays
set_input_delay  0 [all_inputs]
set_output_delay 0 [all_outputs]

# Control delays
group_path    -from $all_ctl -to $all_pins_um_ctl -name ctl_to_ctl
set_max_delay -from $all_ctl -to $all_pins_um_ctl 15.0

group_path    -from $all_ctl -to $all_pins_um_iw  -name ctl_to_inward
set_max_delay -from $all_ctl -to $all_pins_um_iw  15.0

group_path    -from $all_ctl -to $all_pads_out    -name ctl_to_outward
set_max_delay -from $all_ctl -to $all_pads_out    30.0

# User IO
group_path    -from $all_pads_in    -to $all_pins_um_iw  -name io_inward
set_max_delay -from $all_pads_in    -to $all_pins_um_iw  5.0

group_path    -from $all_pins_um_ow -to $all_pads_out    -name io_outward
set_max_delay -from $all_pins_um_ow -to $all_pads_out    12.5
