cellname rename (UNNAMED) tt_pg_3v3_2

box position 0 0
box height 22576
box width 1380
property FIXED_BBOX [box values]

box position 0 0
box heigh 22424
box width 120
paint met4
label VDPWR FreeSans 20 0 0 0 center -met4
port make
port class input
port use ground

box position 170 0
paint met4
label VGND FreeSans 20 0 0 0 center -met4
port make
port class input
port use ground

box width 495
box position 340 0
paint met4
label VAPWR FreeSans 20 0 0 0 center -met4
port make
port class input
port use power 

box position 885 0
paint met4
label GAPWR FreeSans 20 0 0 0 center -met4
port make
port class output
port use power 

box height 50
box width 1380
box position 0 22526
paint met4
label ctrl FreeSans 20 0 0 0 center -met4
port make
port class input
port use signal

save tt_pg_3v3_2.mag
gds write ../gds/tt_pg_3v3_2.gds
lef write ../lef/tt_pg_3v3_2.lef -hide -pinonly
