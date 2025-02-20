cellname rename (UNNAMED) tt_pg_1v8_ll_1

box position 0 0
box height 11152
box width 920
property FIXED_BBOX [box values]

box position 0 0
box heigh 11000
box width 120
paint met4
label VGND FreeSans 20 0 0 0 center -met4
port make
port class input
port use ground

box width 350
box position 170 0
paint met4
label VPWR FreeSans 20 0 0 0 center -met4
port make
port class input
port use power 

box position 570 0
paint met4
label GPWR FreeSans 20 0 0 0 center -met4
port make
port class output
port use power 

box height 50
box width 920
box position 0 11102
paint met4
label ctrl FreeSans 20 0 0 0 center -met4
port make
port class input
port use signal

select top cell
lef write ../lef/tt_pg_1v8_ll_1.lef -hide -pinonly
gds write ../gds/tt_pg_1v8_ll_1.gds
save tt_pg_1v8_ll_1.mag
