cellname rename (UNNAMED) tt_pg_vdd_2

box position 0 0
box height 22576
box width 920
property FIXED_BBOX [box values]

box position 0 0
box heigh 22424
box width 120
paint met4
label VGND
port make
port class input
port use ground

box position 800 0
paint met4
label VGND
port make
port class input
port use ground

box width 265
box position 170 0
paint met4
label VPWR
port make
port class input
port use power 

box position 485 0
paint met4
label GPWR
port make
port class output
port use power 

box height 50
box width 920
box position 0 22526
paint met4
label ctrl
port make
port class input
port use signal

lef write ../lef/tt_pg_vdd_2.lef -hide -pinonly
gds write ../gds/tt_pg_vdd_2.gds
save tt_pg_vdd_2.mag
