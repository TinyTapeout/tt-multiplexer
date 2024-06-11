#
# Updates final GDS/LEF
#

# Load cell
set project [lindex $argv $argc-1]
load $project

# GDS
gds write ../gds/$project.gds

# LEF
lef write ../lef/$project.lef -pinonly -hide

# Done
quit -noprompt
