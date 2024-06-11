#
# Extract a given mag to a .spice file for LVS
#

# Load cell
set project [lindex $argv $argc-1]
load $project
select top cell

# Run extraction
extract path ext
extract all

# Convert to SPICE
ext2spice lvs
ext2spice cthresh infinite
ext2spice short resistor
ext2spice -p ext -o $project.lvs.spice

# Done
quit -noprompt
