v {xschem version=3.4.5 file_version=1.2
}
G {}
K {}
V {}
S {}
E {}
T {1.8V Power Gate} 680 -110 0 0 0.4 0.4 {}
T {Active
Discharge} 1050 -520 0 0 0.2 0.2 {}
N 240 -430 260 -430 {
lab=ctrl}
N 240 -430 240 -330 {
lab=ctrl}
N 240 -330 260 -330 {
lab=ctrl}
N 200 -380 240 -380 {
lab=ctrl}
N 300 -400 300 -360 {
lab=ctrl_n}
N 300 -380 380 -380 {
lab=ctrl_n}
N 190 -160 540 -160 {
lab=VGND}
N 200 -600 300 -600 {
lab=VPWR}
N 300 -600 520 -600 {
lab=VPWR}
N 580 -600 670 -600 {
lab=GPWR}
N 540 -160 620 -160 {
lab=VGND}
N 670 -420 670 -400 {
lab=#net1}
N 670 -340 670 -320 {
lab=#net2}
N 670 -260 670 -240 {
lab=#net3}
N 790 -420 790 -400 {
lab=#net4}
N 790 -340 790 -320 {
lab=#net5}
N 790 -260 790 -240 {
lab=#net6}
N 630 -450 750 -450 {
lab=ctrl_n}
N 630 -370 750 -370 {
lab=ctrl_n}
N 630 -290 750 -290 {
lab=ctrl_n}
N 630 -210 750 -210 {
lab=ctrl_n}
N 790 -180 790 -160 {
lab=VGND}
N 670 -180 670 -160 {
lab=VGND}
N 670 -520 670 -480 {
lab=#net7}
N 670 -500 790 -500 {
lab=#net7}
N 790 -500 790 -480 {
lab=#net7}
N 550 -560 550 -380 {
lab=ctrl_n}
N 380 -380 550 -380 {
lab=ctrl_n}
N 610 -450 630 -450 {
lab=ctrl_n}
N 610 -450 610 -210 {
lab=ctrl_n}
N 610 -210 630 -210 {
lab=ctrl_n}
N 550 -380 610 -380 {
lab=ctrl_n}
N 610 -370 630 -370 {
lab=ctrl_n}
N 610 -290 630 -290 {
lab=ctrl_n}
N 670 -600 670 -580 {
lab=GPWR}
N 670 -600 870 -600 {
lab=GPWR}
N 300 -300 300 -160 {
lab=VGND}
N 300 -600 300 -460 {
lab=VPWR}
N -70 -160 190 -160 {
lab=VGND}
N -70 -600 200 -600 {
lab=VPWR}
N 40 -600 40 -410 {
lab=VPWR}
N 40 -350 40 -160 {
lab=VGND}
N 1110 -600 1330 -600 {
lab=GPWR}
N 1240 -600 1240 -410 {
lab=GPWR}
N 1030 -160 1240 -160 {
lab=VGND}
N 1240 -350 1240 -160 {
lab=VGND}
N 910 -420 910 -400 {
lab=#net8}
N 910 -340 910 -320 {
lab=#net9}
N 910 -260 910 -240 {
lab=#net10}
N 750 -450 870 -450 {
lab=ctrl_n}
N 750 -370 870 -370 {
lab=ctrl_n}
N 750 -290 870 -290 {
lab=ctrl_n}
N 750 -210 870 -210 {
lab=ctrl_n}
N 910 -180 910 -160 {
lab=VGND}
N 790 -500 910 -500 {
lab=#net7}
N 910 -500 910 -480 {
lab=#net7}
N 1030 -420 1030 -400 {
lab=#net11}
N 1030 -340 1030 -320 {
lab=#net12}
N 1030 -260 1030 -240 {
lab=#net13}
N 870 -450 990 -450 {
lab=ctrl_n}
N 870 -370 990 -370 {
lab=ctrl_n}
N 870 -290 990 -290 {
lab=ctrl_n}
N 870 -210 990 -210 {
lab=ctrl_n}
N 1030 -180 1030 -160 {
lab=VGND}
N 910 -500 1030 -500 {
lab=#net7}
N 1030 -500 1030 -480 {
lab=#net7}
N 870 -600 1110 -600 {
lab=GPWR}
N 620 -160 1030 -160 {
lab=VGND}
C {devices/title.sym} 160 -30 0 0 {name=l1 author="Sylvain Munaut"}
C {devices/ipin.sym} 200 -380 2 1 {name=p5 lab=ctrl sim_pinnumber=3}
C {devices/iopin.sym} -70 -160 2 0 {name=p8 lab=VGND sim_pinnumber=1}
C {devices/iopin.sym} -70 -600 2 0 {name=p9 lab=VPWR sim_pinnumber=2}
C {sky130_fd_pr/nfet3_01v8.sym} 280 -330 0 0 {name=M2
W=7
L=0.15
body=VGND
nf=4
mult=1
ad="'int((nf+1)/2) * W/nf * 0.29'" 
pd="'2*int((nf+1)/2) * (W/nf + 0.29)'"
as="'int((nf+2)/2) * W/nf * 0.29'" 
ps="'2*int((nf+2)/2) * (W/nf + 0.29)'"
nrd="'0.29 / W'" nrs="'0.29 / W'"
sa=0 sb=0 sd=0
model=nfet_01v8
spiceprefix=X
}
C {sky130_fd_pr/pfet3_01v8_hvt.sym} 280 -430 0 0 {name=M1
W=21
L=0.15
body=VPWR
nf=4
mult=1
ad="'int((nf+1)/2) * W/nf * 0.29'" 
pd="'2*int((nf+1)/2) * (W/nf + 0.29)'"
as="'int((nf+2)/2) * W/nf * 0.29'" 
ps="'2*int((nf+2)/2) * (W/nf + 0.29)'"
nrd="'0.29 / W'" nrs="'0.29 / W'"
sa=0 sb=0 sd=0
model=pfet_01v8_hvt
spiceprefix=X
}
C {devices/lab_wire.sym} 380 -380 0 1 {name=p10 sig_type=std_logic lab=ctrl_n}
C {sky130_fd_pr/pfet3_01v8_hvt.sym} 550 -580 3 0 {name=M3
W=8424.5
L=0.15
body=VPWR
nf=1162
mult=1
ad="'int((nf+1)/2) * W/nf * 0.29'" 
pd="'2*int((nf+1)/2) * (W/nf + 0.29)'"
as="'int((nf+2)/2) * W/nf * 0.29'" 
ps="'2*int((nf+2)/2) * (W/nf + 0.29)'"
nrd="'0.29 / W'" nrs="'0.29 / W'"
sa=0 sb=0 sd=0
model=pfet_01v8_hvt
spiceprefix=X
}
C {sky130_fd_pr/nfet3_01v8.sym} 650 -450 0 0 {name=M4
W=1
L=0.5
body=VGND
nf=1
mult=1
ad="'int((nf+1)/2) * W/nf * 0.29'" 
pd="'2*int((nf+1)/2) * (W/nf + 0.29)'"
as="'int((nf+2)/2) * W/nf * 0.29'" 
ps="'2*int((nf+2)/2) * (W/nf + 0.29)'"
nrd="'0.29 / W'" nrs="'0.29 / W'"
sa=0 sb=0 sd=0
model=nfet_01v8
spiceprefix=X
}
C {devices/iopin.sym} 1330 -600 0 0 {name=p1 lab=GPWR sim_pinnumber=4}
C {devices/ammeter.sym} 670 -550 0 0 {name=Vdischg savecurrent=true spice_ignore=0 lvs_ignore=short}
C {sky130_fd_pr/nfet3_01v8.sym} 650 -370 0 0 {name=M5
W=1
L=0.5
body=VGND
nf=1
mult=1
ad="'int((nf+1)/2) * W/nf * 0.29'" 
pd="'2*int((nf+1)/2) * (W/nf + 0.29)'"
as="'int((nf+2)/2) * W/nf * 0.29'" 
ps="'2*int((nf+2)/2) * (W/nf + 0.29)'"
nrd="'0.29 / W'" nrs="'0.29 / W'"
sa=0 sb=0 sd=0
model=nfet_01v8
spiceprefix=X
}
C {sky130_fd_pr/nfet3_01v8.sym} 650 -290 0 0 {name=M6
W=1
L=0.5
body=VGND
nf=1
mult=1
ad="'int((nf+1)/2) * W/nf * 0.29'" 
pd="'2*int((nf+1)/2) * (W/nf + 0.29)'"
as="'int((nf+2)/2) * W/nf * 0.29'" 
ps="'2*int((nf+2)/2) * (W/nf + 0.29)'"
nrd="'0.29 / W'" nrs="'0.29 / W'"
sa=0 sb=0 sd=0
model=nfet_01v8
spiceprefix=X
}
C {sky130_fd_pr/nfet3_01v8.sym} 650 -210 0 0 {name=M7
W=1
L=0.5
body=VGND
nf=1
mult=1
ad="'int((nf+1)/2) * W/nf * 0.29'" 
pd="'2*int((nf+1)/2) * (W/nf + 0.29)'"
as="'int((nf+2)/2) * W/nf * 0.29'" 
ps="'2*int((nf+2)/2) * (W/nf + 0.29)'"
nrd="'0.29 / W'" nrs="'0.29 / W'"
sa=0 sb=0 sd=0
model=nfet_01v8
spiceprefix=X
}
C {sky130_fd_pr/nfet3_01v8.sym} 770 -450 0 0 {name=M8
W=1
L=0.5
body=VGND
nf=1
mult=1
ad="'int((nf+1)/2) * W/nf * 0.29'" 
pd="'2*int((nf+1)/2) * (W/nf + 0.29)'"
as="'int((nf+2)/2) * W/nf * 0.29'" 
ps="'2*int((nf+2)/2) * (W/nf + 0.29)'"
nrd="'0.29 / W'" nrs="'0.29 / W'"
sa=0 sb=0 sd=0
model=nfet_01v8
spiceprefix=X
}
C {sky130_fd_pr/nfet3_01v8.sym} 770 -370 0 0 {name=M9
W=1
L=0.5
body=VGND
nf=1
mult=1
ad="'int((nf+1)/2) * W/nf * 0.29'" 
pd="'2*int((nf+1)/2) * (W/nf + 0.29)'"
as="'int((nf+2)/2) * W/nf * 0.29'" 
ps="'2*int((nf+2)/2) * (W/nf + 0.29)'"
nrd="'0.29 / W'" nrs="'0.29 / W'"
sa=0 sb=0 sd=0
model=nfet_01v8
spiceprefix=X
}
C {sky130_fd_pr/nfet3_01v8.sym} 770 -290 0 0 {name=M10
W=1
L=0.5
body=VGND
nf=1
mult=1
ad="'int((nf+1)/2) * W/nf * 0.29'" 
pd="'2*int((nf+1)/2) * (W/nf + 0.29)'"
as="'int((nf+2)/2) * W/nf * 0.29'" 
ps="'2*int((nf+2)/2) * (W/nf + 0.29)'"
nrd="'0.29 / W'" nrs="'0.29 / W'"
sa=0 sb=0 sd=0
model=nfet_01v8
spiceprefix=X
}
C {sky130_fd_pr/nfet3_01v8.sym} 770 -210 0 0 {name=M11
W=1
L=0.5
body=VGND
nf=1
mult=1
ad="'int((nf+1)/2) * W/nf * 0.29'" 
pd="'2*int((nf+1)/2) * (W/nf + 0.29)'"
as="'int((nf+2)/2) * W/nf * 0.29'" 
ps="'2*int((nf+2)/2) * (W/nf + 0.29)'"
nrd="'0.29 / W'" nrs="'0.29 / W'"
sa=0 sb=0 sd=0
model=nfet_01v8
spiceprefix=X
}
C {sky130_fd_pr/cap_mim_m3_1.sym} 40 -380 0 0 {name=C1 model=cap_mim_m3_1 W=6.9 L=19.4 MF=6 spiceprefix=X}
C {sky130_fd_pr/cap_mim_m3_1.sym} 1240 -380 0 0 {name=C2 model=cap_mim_m3_1 W=6.9 L=19.4 MF=9 spiceprefix=X}
C {sky130_fd_pr/nfet3_01v8.sym} 890 -450 0 0 {name=M12
W=1
L=0.5
body=VGND
nf=1
mult=1
ad="'int((nf+1)/2) * W/nf * 0.29'" 
pd="'2*int((nf+1)/2) * (W/nf + 0.29)'"
as="'int((nf+2)/2) * W/nf * 0.29'" 
ps="'2*int((nf+2)/2) * (W/nf + 0.29)'"
nrd="'0.29 / W'" nrs="'0.29 / W'"
sa=0 sb=0 sd=0
model=nfet_01v8
spiceprefix=X
}
C {sky130_fd_pr/nfet3_01v8.sym} 890 -370 0 0 {name=M13
W=1
L=0.5
body=VGND
nf=1
mult=1
ad="'int((nf+1)/2) * W/nf * 0.29'" 
pd="'2*int((nf+1)/2) * (W/nf + 0.29)'"
as="'int((nf+2)/2) * W/nf * 0.29'" 
ps="'2*int((nf+2)/2) * (W/nf + 0.29)'"
nrd="'0.29 / W'" nrs="'0.29 / W'"
sa=0 sb=0 sd=0
model=nfet_01v8
spiceprefix=X
}
C {sky130_fd_pr/nfet3_01v8.sym} 890 -290 0 0 {name=M14
W=1
L=0.5
body=VGND
nf=1
mult=1
ad="'int((nf+1)/2) * W/nf * 0.29'" 
pd="'2*int((nf+1)/2) * (W/nf + 0.29)'"
as="'int((nf+2)/2) * W/nf * 0.29'" 
ps="'2*int((nf+2)/2) * (W/nf + 0.29)'"
nrd="'0.29 / W'" nrs="'0.29 / W'"
sa=0 sb=0 sd=0
model=nfet_01v8
spiceprefix=X
}
C {sky130_fd_pr/nfet3_01v8.sym} 890 -210 0 0 {name=M15
W=1
L=0.5
body=VGND
nf=1
mult=1
ad="'int((nf+1)/2) * W/nf * 0.29'" 
pd="'2*int((nf+1)/2) * (W/nf + 0.29)'"
as="'int((nf+2)/2) * W/nf * 0.29'" 
ps="'2*int((nf+2)/2) * (W/nf + 0.29)'"
nrd="'0.29 / W'" nrs="'0.29 / W'"
sa=0 sb=0 sd=0
model=nfet_01v8
spiceprefix=X
}
C {sky130_fd_pr/nfet3_01v8.sym} 1010 -450 0 0 {name=M16
W=1
L=0.5
body=VGND
nf=1
mult=1
ad="'int((nf+1)/2) * W/nf * 0.29'" 
pd="'2*int((nf+1)/2) * (W/nf + 0.29)'"
as="'int((nf+2)/2) * W/nf * 0.29'" 
ps="'2*int((nf+2)/2) * (W/nf + 0.29)'"
nrd="'0.29 / W'" nrs="'0.29 / W'"
sa=0 sb=0 sd=0
model=nfet_01v8
spiceprefix=X
}
C {sky130_fd_pr/nfet3_01v8.sym} 1010 -370 0 0 {name=M17
W=1
L=0.5
body=VGND
nf=1
mult=1
ad="'int((nf+1)/2) * W/nf * 0.29'" 
pd="'2*int((nf+1)/2) * (W/nf + 0.29)'"
as="'int((nf+2)/2) * W/nf * 0.29'" 
ps="'2*int((nf+2)/2) * (W/nf + 0.29)'"
nrd="'0.29 / W'" nrs="'0.29 / W'"
sa=0 sb=0 sd=0
model=nfet_01v8
spiceprefix=X
}
C {sky130_fd_pr/nfet3_01v8.sym} 1010 -290 0 0 {name=M18
W=1
L=0.5
body=VGND
nf=1
mult=1
ad="'int((nf+1)/2) * W/nf * 0.29'" 
pd="'2*int((nf+1)/2) * (W/nf + 0.29)'"
as="'int((nf+2)/2) * W/nf * 0.29'" 
ps="'2*int((nf+2)/2) * (W/nf + 0.29)'"
nrd="'0.29 / W'" nrs="'0.29 / W'"
sa=0 sb=0 sd=0
model=nfet_01v8
spiceprefix=X
}
C {sky130_fd_pr/nfet3_01v8.sym} 1010 -210 0 0 {name=M19
W=1
L=0.5
body=VGND
nf=1
mult=1
ad="'int((nf+1)/2) * W/nf * 0.29'" 
pd="'2*int((nf+1)/2) * (W/nf + 0.29)'"
as="'int((nf+2)/2) * W/nf * 0.29'" 
ps="'2*int((nf+2)/2) * (W/nf + 0.29)'"
nrd="'0.29 / W'" nrs="'0.29 / W'"
sa=0 sb=0 sd=0
model=nfet_01v8
spiceprefix=X
}
