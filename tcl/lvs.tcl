set layout [readnet spice $project.lvs.spice]
set schem  [readnet spice ../xschem/simulation/$project.spice]
lvs "$layout $project" "$schem $project" $::env(PDK_ROOT)/sky130A/libs.tech/netgen/sky130A_setup.tcl lvs.report -blackbox

