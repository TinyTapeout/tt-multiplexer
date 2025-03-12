source $::env(SCRIPTS_DIR)/openroad/common/io.tcl

read_current_odb

set IO_LENGTH 180
set IO_WIDTH 80
set BONDPAD_SIZE 70
set SEALRING_OFFSET 70
set MAX_NUM_PADS_HORIZONTAL 14
set MAX_NUM_PADS_VERTICAL 18

set PAD_IDX_OFFSET 1
set PAD_IDX_COUNT [expr ($MAX_NUM_PADS_HORIZONTAL + $MAX_NUM_PADS_VERTICAL)*2]

proc calc_horizontal_pad_location {index} {
    global IO_LENGTH
    global IO_WIDTH
    global BONDPAD_SIZE
    global MAX_NUM_PADS_HORIZONTAL
    global SEALRING_OFFSET

    set DIE_WIDTH [expr {[lindex $::env(DIE_AREA) 2] - [lindex $::env(DIE_AREA) 0]}]
    set PAD_OFFSET [expr {$IO_LENGTH + $BONDPAD_SIZE + $SEALRING_OFFSET}]
    set PAD_AREA_WIDTH [expr {$DIE_WIDTH - ($PAD_OFFSET * 2)}]
    set HORIZONTAL_PAD_DISTANCE [expr {($PAD_AREA_WIDTH / $MAX_NUM_PADS_HORIZONTAL) - $IO_WIDTH}]

    return [expr {$PAD_OFFSET + (($IO_WIDTH + $HORIZONTAL_PAD_DISTANCE) * $index) + ($HORIZONTAL_PAD_DISTANCE / 2)}]
}

proc calc_vertical_pad_location {index} {
    global IO_LENGTH
    global IO_WIDTH
    global BONDPAD_SIZE
    global MAX_NUM_PADS_VERTICAL
    global SEALRING_OFFSET

    set DIE_HEIGHT [expr {[lindex $::env(DIE_AREA) 3] - [lindex $::env(DIE_AREA) 1]}]
    set PAD_OFFSET [expr {$IO_LENGTH + $BONDPAD_SIZE + $SEALRING_OFFSET}]
    set PAD_AREA_HEIGHT [expr {$DIE_HEIGHT - ($PAD_OFFSET * 2)}]
    set VERTICAL_PAD_DISTANCE [expr {($PAD_AREA_HEIGHT / $MAX_NUM_PADS_VERTICAL) - $IO_WIDTH}]

    return [expr {$PAD_OFFSET + (($IO_WIDTH + $VERTICAL_PAD_DISTANCE) * $index) + ($VERTICAL_PAD_DISTANCE / 2)}]
}

proc get_io {index} {
	foreach inst [[ord::get_db_block] getInsts] {
		if { [string match "gpio\\\\\\\[$index\\\\\\\]*" "[$inst getName]"] } {
			return "[$inst getName]"
		}
	}
}

make_fake_io_site -name IOLibSite -width 1 -height $IO_LENGTH
make_fake_io_site -name IOLibCSite -width $IO_LENGTH -height $IO_LENGTH

set IO_OFFSET [expr {$BONDPAD_SIZE + $SEALRING_OFFSET}]
# Create IO Rows
make_io_sites \
    -horizontal_site IOLibSite \
    -vertical_site IOLibSite \
    -corner_site IOLibCSite \
    -offset $IO_OFFSET


# Place Pads
set pad_idx $PAD_IDX_OFFSET

for {set side_idx 0} {$side_idx < $MAX_NUM_PADS_HORIZONTAL} {incr side_idx} {
	puts "$pad_idx $side_idx [get_io $pad_idx]"
	set inst_name [get_io $pad_idx]
	if { "$inst_name" != "" } {
		place_pad -row IO_SOUTH -location [calc_horizontal_pad_location $side_idx] [get_io $pad_idx]
	}
	set pad_idx [ expr ($pad_idx + 1) % $PAD_IDX_COUNT ]
}

for {set side_idx 0} {$side_idx < $MAX_NUM_PADS_VERTICAL} {incr side_idx} {
	puts "$pad_idx $side_idx [get_io $pad_idx]"
	set inst_name [get_io $pad_idx]
	if { "$inst_name" != "" } {
		place_pad -row IO_EAST -location [calc_vertical_pad_location $side_idx] [get_io $pad_idx]
	}
	set pad_idx [ expr ($pad_idx + 1) % $PAD_IDX_COUNT ]
}

for {set side_idx 0} {$side_idx < $MAX_NUM_PADS_HORIZONTAL} {incr side_idx} {
	puts "$pad_idx $side_idx [get_io $pad_idx]"
	set inst_name [get_io $pad_idx]
	if { "$inst_name" != "" } {
		place_pad -row IO_NORTH -location [calc_horizontal_pad_location [expr $MAX_NUM_PADS_HORIZONTAL - $side_idx - 1]] [get_io $pad_idx]
	}
	set pad_idx [ expr ($pad_idx + 1) % $PAD_IDX_COUNT ]
}

for {set side_idx 0} {$side_idx < $MAX_NUM_PADS_VERTICAL} {incr side_idx} {
	puts "$pad_idx $side_idx [get_io $pad_idx]"
	set inst_name [get_io $pad_idx]
	if { "$inst_name" != "" } {
		place_pad -row IO_WEST -location [calc_vertical_pad_location [expr $MAX_NUM_PADS_VERTICAL - $side_idx - 1]] [get_io $pad_idx]
	}
	set pad_idx [ expr ($pad_idx + 1) % $PAD_IDX_COUNT ]
}

# Place Corner Cells and Filler
place_corners sg13g2_Corner

set iofill {
    sg13g2_Filler10000
    sg13g2_Filler4000
    sg13g2_Filler2000
    sg13g2_Filler1000
    sg13g2_Filler400
    sg13g2_Filler200
}

place_io_fill -row IO_NORTH {*}$iofill
place_io_fill -row IO_SOUTH {*}$iofill
place_io_fill -row IO_WEST {*}$iofill
place_io_fill -row IO_EAST {*}$iofill

connect_by_abutment

place_bondpad -bond bondpad_70x70 gpio\[*\].* -offset {5.0 -70.0}

remove_io_rows

write_views
