set layout [readnet spice $project.lvs.spice]
set schem  [readnet spice ../xschem/simulation/$project.spice]
lvs "$layout $project" "$schem $project" $::env(PDK_ROOT)/$::env(PDK)/libs.tech/netgen/$::env(PDK)_setup.tcl lvs.report -blackbox
