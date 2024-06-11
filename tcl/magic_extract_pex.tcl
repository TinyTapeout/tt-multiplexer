#
# Extract a given mag to a .spice file for PEX
#

# Load cell
set project [lindex $argv $argc-1]
load $project

# Flatten
flatten ${project}_pex
load ${project}_pex
select top cell

# Run extraction
extract path ext
extract all

# Convert to SPICE with parasitics
ext2sim labels on
ext2sim -p ext

extresist tolerance 10
extresist

ext2spice lvs
ext2spice cthresh 0.01
ext2spice extresist on
ext2spice -p ext -o $project.pex.spice

# Done
quit -noprompt
