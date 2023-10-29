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
set_input_transition 0.1 $all_um_outward

# Spine not so much
set_input_transition 1.0 $all_spine_ctl
set_input_transition 1.0 $all_spine_inward


# Loads
# -----

# UM connections are _very_ short
set_load 0.01 $all_um_ctl
set_load 0.01 $all_um_inward

# Spine is very capacitive. 0.75 pF estimate from tt_top max RCX
set_load 0.75 $all_spine_outward


# Assumptions
# -----------

# We assume the pull are disabled since it messes with the analysis
# (STA can't "see" that those are only active when disabled)
set_case_analysis one [get_pins bus_pull_ow_I*/TE_B]


# Max delays
# ----------

# No artifical delays
set_input_delay  0 [all_inputs]
set_output_delay 0 [all_outputs]

# Enable delays are not all that critical
group_path    -from $all_spine_ctl -to $all_um_ctl        -name ctl_to_ctl
set_max_delay -from $all_spine_ctl -to $all_um_ctl        12.5

group_path    -from $all_spine_ctl -to $all_um_inward     -name ctl_to_inward
set_max_delay -from $all_spine_ctl -to $all_um_inward     12.5

group_path    -from $all_spine_ctl -to $all_spine_outward -name ctl_to_outward
set_max_delay -from $all_spine_ctl -to $all_spine_outward 12.5

# User IO should be fast-ish
group_path    -from $all_spine_inward -to $all_um_inward     -name io_inward
set_max_delay -from $all_spine_inward -to $all_um_inward     2.5

group_path    -from $all_um_outward   -to $all_spine_outward -name io_outward
set_max_delay -from $all_um_outward   -to $all_spine_outward 7.5
