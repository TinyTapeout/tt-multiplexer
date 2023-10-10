#
# TT multiplexer STA
#


# Segment signals
# ---------------

# User modules
set all_um_ctl        [ get_ports um_ena ]
set all_um_inward     [ get_ports um_iw* ]
set all_um_outward    [ get_ports um_ow* ]

# Spine
	# [11:1] - Control
set all_spine_ctl [list]
for {set i 1} {$i <= 11} {incr i} {
	lappend all_spine_ctl [ get_ports "spine_iw[$i]" ]
}

	# [30:13] - Inward
set all_spine_inward [list]
for {set i 13} {$i <= 30} {incr i} {
	lappend all_spine_inward [ get_ports "spine_iw[$i]" ]
}

	# Outward
set all_spine_outward [ get_ports spine_ow* ]


# Inputs
# ------

# UM connections are decently fast
set_input_transition 0.2 $all_um_outward

# Spine not so much
set_input_transition 2.0 $all_spine_ctl
set_input_transition 2.0 $all_spine_inward


# Loads
# -----

# UM connections are _very_ short
set_load 0.001 $all_um_ctl
set_load 0.001 $all_um_inward

# Spine is very capacitive. 1pF estimate from tt_top max RCX
set_load 1.000 $all_spine_outward


# Max delays
# ----------

# No artifical delays
set_input_delay  0 [all_inputs]
set_output_delay 0 [all_outputs]

# Enable delays are not all that critical
set_max_delay -from $all_spine_ctl -to $all_um_ctl    17.5
set_max_delay -from $all_spine_ctl -to $all_um_inward 17.5

# User IO should be fast-ish
set_max_delay -from $all_spine_inward -to $all_um_inward     2.5
set_max_delay -from $all_um_outward   -to $all_spine_outward 8.5
