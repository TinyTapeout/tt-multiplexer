v {xschem version=3.4.5 file_version=1.2
}
G {}
K {}
V {}
S {}
E {}
T {1.8V Power Gate} 680 -110 0 0 0.4 0.4 {}
T {Active
Discharge} 940 -520 0 0 0.2 0.2 {}
N 370 -430 390 -430 {
lab=ctrl}
N 370 -430 370 -330 {
lab=ctrl}
N 370 -330 390 -330 {
lab=ctrl}
N 330 -380 370 -380 {
lab=ctrl}
N 430 -400 430 -360 {
lab=ctrl_n}
N 430 -380 510 -380 {
lab=ctrl_n}
N 320 -160 670 -160 {
lab=VGND}
N 330 -600 430 -600 {
lab=VPWR}
N 430 -600 650 -600 {
lab=VPWR}
N 710 -600 800 -600 {
lab=GPWR}
N 670 -160 750 -160 {
lab=VGND}
N 800 -420 800 -400 {
lab=#net1}
N 800 -340 800 -320 {
lab=#net2}
N 800 -260 800 -240 {
lab=#net3}
N 920 -420 920 -400 {
lab=#net4}
N 920 -340 920 -320 {
lab=#net5}
N 920 -260 920 -240 {
lab=#net6}
N 760 -450 880 -450 {
lab=ctrl_n}
N 760 -370 880 -370 {
lab=ctrl_n}
N 760 -290 880 -290 {
lab=ctrl_n}
N 760 -210 880 -210 {
lab=ctrl_n}
N 750 -160 920 -160 {
lab=VGND}
N 920 -180 920 -160 {
lab=VGND}
N 800 -180 800 -160 {
lab=VGND}
N 800 -520 800 -480 {
lab=#net7}
N 800 -500 920 -500 {
lab=#net7}
N 920 -500 920 -480 {
lab=#net7}
N 680 -560 680 -380 {
lab=ctrl_n}
N 510 -380 680 -380 {
lab=ctrl_n}
N 740 -450 760 -450 {
lab=ctrl_n}
N 740 -450 740 -210 {
lab=ctrl_n}
N 740 -210 760 -210 {
lab=ctrl_n}
N 680 -380 740 -380 {
lab=ctrl_n}
N 740 -370 760 -370 {
lab=ctrl_n}
N 740 -290 760 -290 {
lab=ctrl_n}
N 800 -600 800 -580 {
lab=GPWR}
N 800 -600 1000 -600 {
lab=GPWR}
N 430 -300 430 -160 {
lab=VGND}
N 430 -600 430 -460 {
lab=VPWR}
N 60 -160 320 -160 {
lab=VGND}
N 60 -600 330 -600 {
lab=VPWR}
N 170 -600 170 -410 {
lab=VPWR}
N 170 -350 170 -160 {
lab=VGND}
N 1000 -600 1220 -600 {
lab=GPWR}
N 1130 -600 1130 -410 {
lab=GPWR}
N 920 -160 1130 -160 {
lab=VGND}
N 1130 -350 1130 -160 {
lab=VGND}
C {devices/title.sym} 160 -30 0 0 {name=l1 author="Sylvain Munaut"}
C {devices/ipin.sym} 330 -380 2 1 {name=p5 lab=ctrl sim_pinnumber=3}
C {devices/iopin.sym} 60 -160 2 0 {name=p8 lab=VGND sim_pinnumber=1}
C {devices/iopin.sym} 60 -600 2 0 {name=p9 lab=VPWR sim_pinnumber=2}
C {sky130_fd_pr/nfet3_01v8.sym} 410 -330 0 0 {name=M2
W=3.5
L=0.15
body=VGND
nf=2
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
C {sky130_fd_pr/pfet3_01v8_hvt.sym} 410 -430 0 0 {name=M1
W=10.5
L=0.15
body=VPWR
nf=2
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
C {devices/lab_wire.sym} 510 -380 0 1 {name=p10 sig_type=std_logic lab=ctrl_n}
C {sky130_fd_pr/pfet3_01v8_hvt.sym} 680 -580 3 0 {name=M3
W=3683
L=0.15
body=VPWR
nf=508
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
C {sky130_fd_pr/nfet3_01v8.sym} 780 -450 0 0 {name=M4
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
C {devices/iopin.sym} 1220 -600 0 0 {name=p1 lab=GPWR sim_pinnumber=4}
C {devices/ammeter.sym} 800 -550 0 0 {name=Vdischg savecurrent=true spice_ignore=0 lvs_ignore=short}
C {sky130_fd_pr/nfet3_01v8.sym} 780 -370 0 0 {name=M5
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
C {sky130_fd_pr/nfet3_01v8.sym} 780 -290 0 0 {name=M6
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
C {sky130_fd_pr/nfet3_01v8.sym} 780 -210 0 0 {name=M7
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
C {sky130_fd_pr/nfet3_01v8.sym} 900 -450 0 0 {name=M8
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
C {sky130_fd_pr/nfet3_01v8.sym} 900 -370 0 0 {name=M9
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
C {sky130_fd_pr/nfet3_01v8.sym} 900 -290 0 0 {name=M10
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
C {sky130_fd_pr/nfet3_01v8.sym} 900 -210 0 0 {name=M11
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
C {sky130_fd_pr/cap_mim_m3_1.sym} 170 -380 0 0 {name=C1 model=cap_mim_m3_1 W=6.9 L=19.4 MF=2 spiceprefix=X}
C {sky130_fd_pr/cap_mim_m3_1.sym} 1130 -380 0 0 {name=C2 model=cap_mim_m3_1 W=6.9 L=19.4 MF=4 spiceprefix=X}
