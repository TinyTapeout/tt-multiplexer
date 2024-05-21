set project [lindex $argv $argc-1]
load $project.mag
select top cell
drc euclidean on
drc style drc(full)
drc check
set drcresult [drc listall why]
quit -noprompt
