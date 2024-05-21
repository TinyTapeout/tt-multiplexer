set project [lindex $argv $argc-1]
load $project
gds write ../gds/$project.gds
lef write ../lef/$project.lef -pinonly -hide
quit -noprompt
