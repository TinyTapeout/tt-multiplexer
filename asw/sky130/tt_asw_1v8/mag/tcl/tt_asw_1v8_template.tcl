cellname rename (UNNAMED) tt_asw_1v8

# Bounding box
box position 0 0
box height 2176
box width 1840
property FIXED_BBOX [box values]

# Ground
box position 60 0
box height 2176
box width 120
paint met4
label VGND
port make
port class input
port use ground
port index 1

box position 60 1176
box height 1000
paint met3

box position 63 1179
box height 994
box width 114
paint via3

# Power
box position 1660 0
box height 2176
box width 120
paint met4
label VPWR
port make
port class input
port use power
port index 2

box position 1660 1176
box height 1000
paint met3

box position 1663 1179
box height 994
box width 114
paint via3

# Module analog connection
box height 200
box width 90
box position 875 1976
paint met4
label mod
port make
port class inout
port use analog
port index 4
paint met3

box height 194
box width 84
box position 878 1979
paint via3

# Bus analog connection
box height 200
box width 90
box position 875 1176
paint met4
label bus 
port make
port class inout
port use analog
port index 5
paint met3

box height 194
box width 84
box position 878 1179
paint via3

# Control connection
box height 90
box width 30
box position 445 2086
paint met3
label ctrl
port make
port class input
port use signal
port index 3

# Write
lef write tt_asw_1v8.lef -hide -pinonly
gds write tt_asw_1v8.gds
save tt_asw_1v8.mag

