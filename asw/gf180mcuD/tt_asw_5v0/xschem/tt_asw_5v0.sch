v {xschem version=3.4.8RC file_version=1.2}
G {}
K {}
V {}
S {}
E {}
N 80 100 180 100 {lab=VGND}
N 180 20 180 100 {lab=VGND}
N 180 20 200 20 {lab=VGND}
N 80 -140 160 -140 {lab=VDPWR}
N 160 -140 160 -40 {lab=VDPWR}
N 160 -40 200 -40 {lab=VDPWR}
N 70 -20 200 -20 {lab=ctrl}
N 80 -180 180 -180 {lab=VAPWR}
N 180 -180 180 -60 {lab=VAPWR}
N 180 -60 200 -60 {lab=VAPWR}
N 500 -40 580 -40 {lab=tgon_p}
N 500 0 580 0 {lab=tgon_n}
N 760 10 760 40 {lab=mod}
N 760 40 940 40 {lab=mod}
N 940 10 940 40 {lab=mod}
N 850 40 850 100 {lab=mod}
N 850 100 880 100 {lab=mod}
N 760 -80 760 -50 {lab=bus}
N 760 -80 940 -80 {lab=bus}
N 940 -80 940 -50 {lab=bus}
N 850 -140 850 -80 {lab=bus}
N 850 -140 880 -140 {lab=bus}
N 680 -20 720 -20 {lab=tgon_p}
N 980 -20 1020 -20 {lab=tgon_n}
N 680 110 720 110 {lab=tgon_n}
N 760 40 760 80 {lab=mod}
N 760 140 760 160 {lab=VGND}
N 600 160 760 160 {lab=VGND}
N 600 100 600 160 {lab=VGND}
N 180 100 600 100 {lab=VGND}
C {devices/title.sym} 170 190 0 0 {name=l1 author="Sylvain Munaut"}
C {devices/ipin.sym} 70 -20 0 0 {name=p4 lab=ctrl sim_pinnumber=4}
C {devices/iopin.sym} 80 -140 0 1 {name=p2 lab=VDPWR sim_pinnumber=2}
C {devices/iopin.sym} 80 100 0 1 {name=p1 lab=VGND sim_pinnumber=1}
C {devices/iopin.sym} 880 100 0 0 {name=p3 lab=mod sim_pinnumber=5}
C {devices/iopin.sym} 80 -180 0 1 {name=p5 lab=VAPWR sim_pinnumber=3}
C {devices/iopin.sym} 880 -140 0 0 {name=p6 lab=bus sim_pinnumber=6}
C {lv2hv.sym} 350 -20 0 0 {name=x1}
C {devices/lab_wire.sym} 580 -40 0 0 {name=p7 sig_type=std_logic lab=tgon_p}
C {devices/lab_wire.sym} 580 0 0 0 {name=p8 sig_type=std_logic lab=tgon_n}
C {gf180mcuD_pr/pfet3_05v0.sym} 960 -20 0 1 {name=M1
L=0.50u
W=592u
body=VAPWR
nf=16
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
C {gf180mcuD_pr/nfet3_05v0.sym} 740 -20 0 0 {name=M2
L=0.60u
W=217u
body=VGND
nf=7
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
C {devices/lab_wire.sym} 680 -20 0 0 {name=p9 sig_type=std_logic lab=tgon_p}
C {devices/lab_wire.sym} 1020 -20 0 1 {name=p10 sig_type=std_logic lab=tgon_n}
C {gf180mcuD_pr/nfet3_05v0.sym} 740 110 0 0 {name=M3
L=0.60u
W=31u
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
C {devices/lab_wire.sym} 680 110 0 0 {name=p11 sig_type=std_logic lab=tgon_n}
