#
# Updates final GDS/LEF
#

# Prep
units microns
suspendall

# Load cell
set project [lindex $argv $argc-1]
load $project

# Flatten
foreach prop_data [property] {
	set prop_name [lindex $prop_data 0]
	dict set props_save $prop_name [property $prop_name]
}

select top cell
flatten -dotoplabels flat_tmp
load flat_tmp
cellname delete $project
cellname rename flat_tmp $project

dict for {prop_name prop_val} $props_save {
	property $prop_name "$prop_val"
}

# GDS
gds write ../gds/$project.gds

# LEF
lef write ../lef/$project.lef -pinonly -hide

# Done
quit -noprompt
