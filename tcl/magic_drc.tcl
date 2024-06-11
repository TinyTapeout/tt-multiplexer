#
# Run full DRC
#

# Load cell
set project [lindex $argv $argc-1]
load $project
select top cell

# DRC
drc euclidean on
drc style "drc(full)"
drc check
set drcresult [drc listall why]
puts "$drcresult"

# Done
quit -noprompt
