#
# TT controller STA
#


# Segment signals
# ---------------

# Control inputs
set all_ctl      [ get_ports ctrl* ]

# User IOs pads connections
set all_pads_in  [ get_ports "pad_uio_in* pad_ui_in*" ]
set all_pads_out [ get_ports "pad_uio_out* pad_uio_oe_n* pad_uo_out*" ]

# Spine
	# [10:1] - Control
set all_spine_ctl [list]
for {set i 1} {$i <= 10} {incr i} {
	lappend all_spine_ctl [ get_ports "spine_bot_iw[$i] spine_top_iw[$i]" ]
}

	# [28:12] - Inward
set all_spine_inward [list]
for {set i 12} {$i <= 28} {incr i} {
	lappend all_spine_inward [ get_ports "spine_bot_iw[$i] spine_top_iw[$i]" ]
}

	# Outward
set all_spine_outward [ get_ports "spine_bot_ow* spine_top_ow*" ]


# Inputs
# ------

# Estimate from gpio driving 0.35 pF
set_input_transition 0.4 $all_ctl

# Estimate from gpio driving 0.7 pF
set_input_transition 0.8 $all_pads_in

# Estimate from STA from tt_mux
set_input_transition 3.0 $all_spine_outward


# Loads
# -----

# IO connections are faily long, 0.4 pF estimate from tt_top max RCX
set_load 0.4 $all_pads_out

# Spine is very capacitive. 0.75 pF estimate from tt_top max RCX
set_load 0.75 $all_spine_inward


# Clock
# -----

create_clock -name ctrl_inc -period 10 [ get_ports ctrl_sel_inc ]
for {set i 0} {$i < 10} {incr i} {
	create_generated_clock -source [ get_pins "sel_cnt_gen\[$i\].cnt_bit_I.cell0_I/CLK" ] -divide_by 2 [ get_pins "sel_cnt_gen\[$i\].cnt_bit_I.cell0_I/Q_N" ]
}


# Max delays
# ----------

# No artifical delays
set_input_delay  0 [all_inputs]
set_output_delay 0 [all_outputs]

# Control delays are not critical
group_path    -from $all_ctl -to $all_spine_ctl     -name ctl_to_ctl
set_max_delay -from $all_ctl -to $all_spine_ctl     2.5

group_path    -from $all_ctl -to $all_spine_inward  -name ctl_to_inward
set_max_delay -from $all_ctl -to $all_spine_inward  5.0

group_path    -from $all_ctl -to $all_pads_out      -name ctl_to_outward
set_max_delay -from $all_ctl -to $all_pads_out      5.0

# User IO should be fast-ish
group_path    -from $all_pads_in        -to $all_spine_inward  -name io_inward
set_max_delay -from $all_pads_in        -to $all_spine_inward  2.75

group_path    -from $all_spine_outward  -to $all_pads_out      -name io_outward
set_max_delay -from $all_spine_outward  -to $all_pads_out      2.25
