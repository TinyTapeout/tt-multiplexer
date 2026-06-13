v {xschem version=3.4.8RC file_version=1.2}
G {}
K {}
V {}
S {}
E {}
N 80 100 270 100 {lab=VGND}
N 260 -20 280 -20 {lab=ctrl}
N 280 -70 280 -20 {lab=ctrl}
N 280 -70 300 -70 {lab=ctrl}
N 280 30 300 30 {lab=ctrl}
N 280 -20 280 30 {lab=ctrl}
N 340 60 340 100 {lab=VGND}
N 270 100 340 100 {lab=VGND}
N 80 -140 340 -140 {lab=VPWR}
N 340 -140 340 -100 {lab=VPWR}
N 340 -40 340 -0 {lab=ctrl_n}
N 340 -140 460 -140 {lab=VPWR}
N 340 -20 490 -20 {lab=ctrl_n}
N 490 -100 490 -20 {lab=ctrl_n}
N 490 -20 520 -20 {lab=ctrl_n}
N 710 0 730 0 {lab=VGND}
N 730 0 730 100 {lab=VGND}
N 520 -140 860 -140 {lab=GPWR}
N 710 -20 730 -20 {lab=GPWR}
N 730 -140 730 -20 {lab=GPWR}
N 340 100 730 100 {lab=VGND}
C {devices/title.sym} 170 190 0 0 {name=l1 author="Sylvain Munaut"}
C {devices/ipin.sym} 260 -20 0 0 {name=p4 lab=ctrl sim_pinnumber=4}
C {devices/iopin.sym} 80 -140 0 1 {name=p2 lab=VPWR sim_pinnumber=2}
C {devices/iopin.sym} 80 100 0 1 {name=p1 lab=VGND sim_pinnumber=1}
C {devices/iopin.sym} 860 -140 0 0 {name=p3 lab=GPWR sim_pinnumber=3}
C {discharge_3v3.sym} 620 -10 0 0 {name=x1}
C {devices/lab_wire.sym} 470 -20 0 0 {name=p5 sig_type=std_logic lab=ctrl_n}
C {gf180mcuD_pr/nfet3_03v3.sym} 320 30 0 0 {name=M1
L=0.28u
W=2.75u
body=VGND
nf=1
m=1
ad="'int((nf+1)/2) * W/nf * 0.18u'"
pd="'2*int((nf+1)/2) * (W/nf + 0.18u)'"
as="'int((nf+2)/2) * W/nf * 0.18u'"
ps="'2*int((nf+2)/2) * (W/nf + 0.18u)'"
nrd="'0.18u / W'" nrs="'0.18u / W'"
sa=0 sb=0 sd=0
model=nfet_03v3
spiceprefix=X
}
C {gf180mcuD_pr/pfet3_03v3.sym} 320 -70 0 0 {name=M2
L=0.28u
W=5.17u
body=VPWR
nf=1
m=1
ad="'int((nf+1)/2) * W/nf * 0.18u'"
pd="'2*int((nf+1)/2) * (W/nf + 0.18u)'"
as="'int((nf+2)/2) * W/nf * 0.18u'"
ps="'2*int((nf+2)/2) * (W/nf + 0.18u)'"
nrd="'0.18u / W'" nrs="'0.18u / W'"
sa=0 sb=0 sd=0
model=pfet_03v3
spiceprefix=X
}
C {gf180mcuD_pr/pfet3_03v3.sym} 490 -120 3 0 {name=M3
L=0.28u
W=1615u
body=VPWR
nf=190
m=1
ad="'int((nf+1)/2) * W/nf * 0.18u'"
pd="'2*int((nf+1)/2) * (W/nf + 0.18u)'"
as="'int((nf+2)/2) * W/nf * 0.18u'"
ps="'2*int((nf+2)/2) * (W/nf + 0.18u)'"
nrd="'0.18u / W'" nrs="'0.18u / W'"
sa=0 sb=0 sd=0
model=pfet_03v3
spiceprefix=X
}
