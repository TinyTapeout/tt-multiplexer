cellname rename (UNNAMED) tt_pg_1v8_2

box position 0 0
box height 51136
box width 920
property FIXED_BBOX [box values]

box position 0 0
box heigh 50984
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
box position 0 51086
paint met4
label ctrl FreeSans 20 0 0 0 center -met4
port make
port class input
port use signal

select top cell
lef write ../lef/tt_pg_1v8_4.lef -hide -pinonly
gds write ../gds/tt_pg_1v8_4.gds
save tt_pg_1v8_4.mag
