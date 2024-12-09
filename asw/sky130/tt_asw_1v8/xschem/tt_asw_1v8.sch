v {xschem version=3.4.5 file_version=1.2
}
G {}
K {}
V {}
S {}
E {}
T {Transmission gate (incl. inverter)} 380 -190 0 0 0.4 0.4 {}
N 680 -980 1000 -980 { lab=VPWR}
N 840 -740 870 -740 {
lab=bus}
N 840 -640 840 -560 {
lab=bus}
N 840 -560 870 -560 {
lab=bus}
N 930 -740 960 -740 {
lab=mod}
N 960 -640 960 -560 {
lab=mod}
N 930 -560 960 -560 {
lab=mod}
N 960 -640 1080 -640 {
lab=mod}
N 900 -740 900 -700 {
lab=VPWR}
N 900 -700 1000 -700 {
lab=VPWR}
N 900 -600 900 -560 {
lab=VGND}
N 900 -600 1000 -600 {
lab=VGND}
N 1000 -600 1000 -420 {
lab=VGND}
N 840 -740 840 -640 {
lab=bus}
N 960 -740 960 -640 {
lab=mod}
N 680 -420 1000 -420 { lab=VGND}
N 1000 -980 1000 -700 {
lab=VPWR}
N 600 -520 600 -420 {
lab=VGND}
N 600 -550 680 -550 {
lab=VGND}
N 680 -550 680 -420 {
lab=VGND}
N 600 -980 600 -840 {
lab=VPWR}
N 600 -810 680 -810 {
lab=VPWR}
N 680 -980 680 -810 {
lab=VPWR}
N 520 -810 560 -810 {
lab=tgon_n}
N 760 -800 760 -740 {
lab=tgon_n}
N 900 -800 900 -780 {
lab=tgon_n}
N 760 -800 900 -800 {
lab=tgon_n}
N 900 -520 900 -500 {
lab=tgon}
N 500 -980 600 -980 { lab=VPWR}
N 600 -980 680 -980 { lab=VPWR}
N 500 -420 600 -420 { lab=VGND}
N 600 -420 680 -420 { lab=VGND}
N 350 -810 390 -810 {
lab=ctrl}
N 350 -810 350 -700 {
lab=ctrl}
N 350 -700 350 -550 {
lab=ctrl}
N 700 -640 840 -640 {
lab=bus}
N 600 -600 600 -580 {
lab=tgon}
N 770 -500 900 -500 {
lab=tgon}
N 600 -600 770 -600 {
lab=tgon}
N 770 -600 770 -500 {
lab=tgon}
N 430 -980 500 -980 {
lab=VPWR}
N 430 -980 430 -840 {
lab=VPWR}
N 430 -740 430 -580 {
lab=tgon_n}
N 350 -550 390 -550 {
lab=ctrl}
N 520 -810 520 -740 {
lab=tgon_n}
N 520 -740 760 -740 {
lab=tgon_n}
N 520 -740 520 -550 {
lab=tgon_n}
N 520 -550 560 -550 {
lab=tgon_n}
N 430 -420 500 -420 {
lab=VGND}
N 430 -520 430 -420 {
lab=VGND}
N 430 -550 500 -550 {
lab=VGND}
N 500 -550 500 -420 {
lab=VGND}
N 430 -810 500 -810 {
lab=VPWR}
N 500 -980 500 -810 {
lab=VPWR}
N 320 -700 350 -700 {
lab=ctrl}
N 600 -780 600 -600 {
lab=tgon}
N 350 -980 430 -980 {
lab=VPWR}
N 430 -740 520 -740 {
lab=tgon_n}
N 310 -420 430 -420 {
lab=VGND}
N 430 -780 430 -740 {
lab=tgon_n}
C {devices/iopin.sym} 350 -980 2 0 {name=p1 lab=VPWR sim_pinnumber=2}
C {devices/iopin.sym} 310 -420 2 0 {name=p2 lab=VGND sim_pinnumber=1}
C {devices/title.sym} 160 -30 0 0 {name=l1 author="Harald Pretl"}
C {devices/iopin.sym} 1080 -640 0 0 {name=p6 lab=mod sim_pinnumber=4}
C {devices/iopin.sym} 700 -640 0 1 {name=p7 lab=bus sim_pinnumber=5}
C {sky130_fd_pr/nfet_01v8.sym} 580 -550 0 0 {name=M4
L=0.15
W=1.5
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
C {sky130_fd_pr/pfet_01v8.sym} 580 -810 0 0 {name=M3
L=0.15
W=3
nf=2
mult=1
ad="'int((nf+1)/2) * W/nf * 0.29'" 
pd="'2*int((nf+1)/2) * (W/nf + 0.29)'"
as="'int((nf+2)/2) * W/nf * 0.29'" 
ps="'2*int((nf+2)/2) * (W/nf + 0.29)'"
nrd="'0.29 / W'" nrs="'0.29 / W'"
sa=0 sb=0 sd=0
model=pfet_01v8
spiceprefix=X
}
C {devices/lab_wire.sym} 700 -740 0 0 {name=p3 sig_type=std_logic lab=tgon_n}
C {devices/lab_wire.sym} 700 -600 0 0 {name=p4 sig_type=std_logic lab=tgon}
C {devices/ipin.sym} 320 -700 2 1 {name=p5 lab=ctrl sim_pinnumber=3}
C {sky130_fd_pr/nfet_01v8.sym} 410 -550 0 0 {name=M2
L=0.15
W=1.5
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
C {sky130_fd_pr/pfet_01v8.sym} 410 -810 0 0 {name=M1
L=0.15
W=3
nf=2
mult=1
ad="'int((nf+1)/2) * W/nf * 0.29'" 
pd="'2*int((nf+1)/2) * (W/nf + 0.29)'"
as="'int((nf+2)/2) * W/nf * 0.29'" 
ps="'2*int((nf+2)/2) * (W/nf + 0.29)'"
nrd="'0.29 / W'" nrs="'0.29 / W'"
sa=0 sb=0 sd=0
model=pfet_01v8
spiceprefix=X
}
C {sky130_fd_pr/nfet_01v8_lvt.sym} 900 -540 3 0 {name=M6
L=0.35
W=31.5
nf=7
mult=1
ad="'int((nf+1)/2) * W/nf * 0.29'" 
pd="'2*int((nf+1)/2) * (W/nf + 0.29)'"
as="'int((nf+2)/2) * W/nf * 0.29'" 
ps="'2*int((nf+2)/2) * (W/nf + 0.29)'"
nrd="'0.29 / W'" nrs="'0.29 / W'"
sa=0 sb=0 sd=0
model=nfet_01v8_lvt
spiceprefix=X
}
C {sky130_fd_pr/pfet_01v8_lvt.sym} 900 -760 1 0 {name=M5
L=0.35
W=94.5
nf=21
mult=1
ad="'int((nf+1)/2) * W/nf * 0.29'" 
pd="'2*int((nf+1)/2) * (W/nf + 0.29)'"
as="'int((nf+2)/2) * W/nf * 0.29'" 
ps="'2*int((nf+2)/2) * (W/nf + 0.29)'"
nrd="'0.29 / W'" nrs="'0.29 / W'"
sa=0 sb=0 sd=0
model=pfet_01v8_lvt
spiceprefix=X
}
