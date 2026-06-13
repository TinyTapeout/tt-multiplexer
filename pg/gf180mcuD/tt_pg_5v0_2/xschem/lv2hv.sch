v {xschem version=3.4.8RC file_version=1.2}
G {}
K {}
V {}
S {}
E {}
N 100 -170 100 -120 {lab=in}
N 100 -170 120 -170 {lab=in}
N 100 -70 120 -70 {lab=in}
N 100 -120 100 -70 {lab=in}
N 160 -40 160 0 {lab=VGND}
N 160 -240 160 -200 {lab=VDPWR}
N 160 -140 160 -100 {lab=in_n}
N 780 -140 780 -100 {lab=#net1}
N 960 -140 960 -100 {lab=#net2}
N 780 -40 780 0 {lab=VGND}
N 960 -40 960 0 {lab=VGND}
N 780 -120 840 -120 {lab=#net1}
N 820 -170 840 -170 {lab=#net2}
N 900 -170 920 -170 {lab=#net1}
N 900 -120 960 -120 {lab=#net2}
N 840 -170 900 -120 {lab=#net2}
N 840 -120 900 -170 {lab=#net1}
N 700 -70 740 -70 {lab=in_p}
N 1000 -70 1040 -70 {lab=in_n}
N 1100 -70 1120 -70 {lab=#net2}
N 1100 -170 1100 -70 {lab=#net2}
N 1100 -170 1120 -170 {lab=#net2}
N 960 -120 1100 -120 {lab=#net2}
N 1160 -140 1160 -100 {lab=out_n}
N 1160 -40 1160 0 {lab=VGND}
N 1160 -320 1160 -200 {lab=VAPWR}
N 960 -320 960 -200 {lab=VAPWR}
N 780 -320 780 -200 {lab=VAPWR}
N 620 -70 640 -70 {lab=#net1}
N 640 -170 640 -70 {lab=#net1}
N 620 -170 640 -170 {lab=#net1}
N 640 -120 780 -120 {lab=#net1}
N 580 -140 580 -100 {lab=out_p}
N 580 -40 580 0 {lab=VGND}
N 580 -320 580 -200 {lab=VAPWR}
N 60 -120 100 -120 {lab=in}
N 1160 -120 1200 -120 {lab=out_n}
N 540 -120 580 -120 {lab=out_p}
N 260 -170 260 -120 {lab=in_n}
N 260 -170 280 -170 {lab=in_n}
N 260 -70 280 -70 {lab=in_n}
N 260 -120 260 -70 {lab=in_n}
N 320 -40 320 0 {lab=VGND}
N 320 -240 320 -200 {lab=VDPWR}
N 320 -140 320 -100 {lab=in_p}
N 320 -120 380 -120 {lab=in_p}
N 60 -240 320 -240 {lab=VDPWR}
N 60 -320 1160 -320 {lab=VAPWR}
N 60 -0 1160 0 {lab=VGND}
N 160 -120 260 -120 {lab=in_n}
C {devices/title.sym} 180 100 0 0 {name=l1 author="Sylvain Munaut"}
C {devices/iopin.sym} 60 -320 0 1 {name=p2 lab=VAPWR sim_pinnumber=3}
C {devices/iopin.sym} 60 0 0 1 {name=p1 lab=VGND sim_pinnumber=1}
C {devices/ipin.sym} 60 -120 0 0 {name=p3 lab=in sim_pinnumber=4}
C {devices/iopin.sym} 60 -240 0 1 {name=p5 lab=VDPWR sim_pinnumber=2}
C {devices/opin.sym} 540 -120 0 1 {name=p6 lab=out_p sim_pinnumber=5}
C {devices/opin.sym} 1200 -120 0 0 {name=p7 lab=out_n im_pinnumber=6}
C {gf180mcuD_pr/nfet3_03v3.sym} 140 -70 0 0 {name=M1
L=0.28u
W=0.89u
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
C {gf180mcuD_pr/pfet3_03v3.sym} 140 -170 0 0 {name=M2
L=0.28u
W=2.0u
body=VDPWR
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
C {gf180mcuD_pr/nfet3_05v0.sym} 760 -70 2 1 {name=M3
L=0.6u
W=0.5u
body=VGND
nf=1
m=1
ad="'int((nf+1)/2) * W/nf * 0.18u'"
pd="'2*int((nf+1)/2) * (W/nf + 0.18u)'"
as="'int((nf+2)/2) * W/nf * 0.18u'"
ps="'2*int((nf+2)/2) * (W/nf + 0.18u)'"
nrd="'0.18u / W'" nrs="'0.18u / W'"
sa=0 sb=0 sd=0
model=nfet_05v0
spiceprefix=X
}
C {gf180mcuD_pr/pfet3_05v0.sym} 800 -170 0 1 {name=M4
L=0.5u
W=0.5u
body=VAPWR
nf=1
m=1
ad="'int((nf+1)/2) * W/nf * 0.18u'"
pd="'2*int((nf+1)/2) * (W/nf + 0.18u)'"
as="'int((nf+2)/2) * W/nf * 0.18u'"
ps="'2*int((nf+2)/2) * (W/nf + 0.18u)'"
nrd="'0.18u / W'" nrs="'0.18u / W'"
sa=0 sb=0 sd=0
model=pfet_05v0
spiceprefix=X
}
C {devices/lab_wire.sym} 220 -120 0 1 {name=p4 sig_type=std_logic lab=in_n}
C {gf180mcuD_pr/nfet3_05v0.sym} 980 -70 0 1 {name=M5
L=0.6u
W=0.5u
body=VGND
nf=1
m=1
ad="'int((nf+1)/2) * W/nf * 0.18u'"
pd="'2*int((nf+1)/2) * (W/nf + 0.18u)'"
as="'int((nf+2)/2) * W/nf * 0.18u'"
ps="'2*int((nf+2)/2) * (W/nf + 0.18u)'"
nrd="'0.18u / W'" nrs="'0.18u / W'"
sa=0 sb=0 sd=0
model=nfet_05v0
spiceprefix=X
}
C {gf180mcuD_pr/pfet3_05v0.sym} 940 -170 0 0 {name=M6
L=0.5u
W=0.5u
body=VAPWR
nf=1
m=1
ad="'int((nf+1)/2) * W/nf * 0.18u'"
pd="'2*int((nf+1)/2) * (W/nf + 0.18u)'"
as="'int((nf+2)/2) * W/nf * 0.18u'"
ps="'2*int((nf+2)/2) * (W/nf + 0.18u)'"
nrd="'0.18u / W'" nrs="'0.18u / W'"
sa=0 sb=0 sd=0
model=pfet_05v0
spiceprefix=X
}
C {devices/lab_wire.sym} 1040 -70 0 1 {name=p8 sig_type=std_logic lab=in_n}
C {devices/lab_wire.sym} 700 -70 0 0 {name=p9 sig_type=std_logic lab=in_p}
C {gf180mcuD_pr/nfet3_05v0.sym} 1140 -70 2 1 {name=M7
L=0.60u
W=0.5u
body=VGND
nf=1
m=1
ad="'int((nf+1)/2) * W/nf * 0.18u'"
pd="'2*int((nf+1)/2) * (W/nf + 0.18u)'"
as="'int((nf+2)/2) * W/nf * 0.18u'"
ps="'2*int((nf+2)/2) * (W/nf + 0.18u)'"
nrd="'0.18u / W'" nrs="'0.18u / W'"
sa=0 sb=0 sd=0
model=nfet_05v0
spiceprefix=X
}
C {gf180mcuD_pr/pfet3_05v0.sym} 1140 -170 0 0 {name=M8
L=0.5u
W=1.0u
body=VAPWR
nf=2
m=1
ad="'int((nf+1)/2) * W/nf * 0.18u'"
pd="'2*int((nf+1)/2) * (W/nf + 0.18u)'"
as="'int((nf+2)/2) * W/nf * 0.18u'"
ps="'2*int((nf+2)/2) * (W/nf + 0.18u)'"
nrd="'0.18u / W'" nrs="'0.18u / W'"
sa=0 sb=0 sd=0
model=pfet_05v0
spiceprefix=X
}
C {gf180mcuD_pr/nfet3_05v0.sym} 600 -70 2 0 {name=M9
L=0.60u
W=0.5u
body=VGND
nf=1
m=1
ad="'int((nf+1)/2) * W/nf * 0.18u'"
pd="'2*int((nf+1)/2) * (W/nf + 0.18u)'"
as="'int((nf+2)/2) * W/nf * 0.18u'"
ps="'2*int((nf+2)/2) * (W/nf + 0.18u)'"
nrd="'0.18u / W'" nrs="'0.18u / W'"
sa=0 sb=0 sd=0
model=nfet_05v0
spiceprefix=X
}
C {gf180mcuD_pr/pfet3_05v0.sym} 600 -170 0 1 {name=M10
L=0.5u
W=1.0u
body=VAPWR
nf=2
m=1
ad="'int((nf+1)/2) * W/nf * 0.18u'"
pd="'2*int((nf+1)/2) * (W/nf + 0.18u)'"
as="'int((nf+2)/2) * W/nf * 0.18u'"
ps="'2*int((nf+2)/2) * (W/nf + 0.18u)'"
nrd="'0.18u / W'" nrs="'0.18u / W'"
sa=0 sb=0 sd=0
model=pfet_05v0
spiceprefix=X
}
C {gf180mcuD_pr/nfet3_03v3.sym} 300 -70 0 0 {name=M11
L=0.28u
W=0.89u
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
C {gf180mcuD_pr/pfet3_03v3.sym} 300 -170 0 0 {name=M12
L=0.28u
W=2.0u
body=VDPWR
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
C {devices/lab_wire.sym} 380 -120 0 1 {name=p10 sig_type=std_logic lab=in_p}
