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

	# [29:12] - Inward
set all_spine_inward [list]
for {set i 12} {$i <= 29} {incr i} {
	lappend all_spine_inward [ get_ports "spine_bot_iw[$i] spine_top_iw[$i]" ]
}

	# Outward
set all_spine_outward [ get_ports "spine_bot_ow* spine_top_ow*" ]


# Inputs
# ------

# Estimate from gpio driving 0.35pF
set_input_transition 0.4 $all_ctl

# Estimate from gpio driving 0.7pF
set_input_transition 0.8 $all_pads_in

# Estimate from STA from tt_mux
set_input_transition 4.0 $all_spine_outward


# Loads
# -----

# IO connections are faily long, 0.4pF estimate from tt_top max RCX
set_load 0.4 $all_pads_out

# Spine is very capacitive. 1pF estimate from tt_top max RCX
set_load 1.0 $all_spine_inward


# Clock
# -----

create_clock -name ctrl_inc -period 10 [ get_ports ctrl_sel_inc ]
for {set i 0} {$i < 10} {incr i} {
	create_generated_clock -source [ get_pins "genblk2\[$i\].cnt_bit_I.cell0_I/CLK" ] -divide_by 2 [ get_pins "genblk2\[$i\].cnt_bit_I.cell0_I/Q_N" ]
}


# Max delays
# ----------

# No artifical delays
set_input_delay  0 [all_inputs]
set_output_delay 0 [all_outputs]

# Control delays are mostly pass through
set_max_delay -from $all_ctl -to $all_spine_ctl     2.0
set_max_delay -from $all_ctl -to $all_spine_inward  2.0

# User IO should be fast-ish
set_max_delay -from $all_pads_in        -to $all_spine_inward  2.5
set_max_delay -from $all_spine_outward  -to $all_pads_out      2.5
