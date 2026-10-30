v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N -140 -120 -120 -120 {lab=gate_pre}
N -120 -170 -120 -120 {lab=gate_pre}
N -120 -170 -100 -170 {lab=gate_pre}
N -120 -70 -100 -70 {lab=gate_pre}
N -120 -120 -120 -70 {lab=gate_pre}
N -60 -40 -60 0 {lab=VGND}
N -60 -240 -60 -200 {lab=VPWR}
N -60 -140 -60 -100 {lab=#net1}
N -140 -240 -60 -240 {lab=VPWR}
N -140 0 -60 0 {lab=VGND}
N 100 -170 100 -120 {lab=#net1}
N 100 -170 120 -170 {lab=#net1}
N 100 -70 120 -70 {lab=#net1}
N 100 -120 100 -70 {lab=#net1}
N 160 -40 160 0 {lab=VGND}
N 160 -240 160 -200 {lab=VPWR}
N 160 -140 160 -100 {lab=gate}
N -60 -120 100 -120 {lab=#net1}
N -60 0 160 0 {lab=VGND}
N -60 -240 160 -240 {lab=VPWR}
N 160 -120 300 -120 {lab=gate}
C {devices/title.sym} -340 100 0 0 {name=l1 author="Sylvain Munaut"}
C {devices/iopin.sym} -140 -240 0 1 {name=p2 lab=VPWR sim_pinnumber=2}
C {devices/iopin.sym} -140 0 0 1 {name=p1 lab=VGND sim_pinnumber=1}
C {devices/ipin.sym} -140 -120 0 0 {name=p3 lab=gate_pre sim_pinnumber=3}
C {devices/opin.sym} 300 -120 0 0 {name=p4 lab=gate sim_pinnumber=4}
C {gf180mcu_fd_pr/nfet3_03v3.sym} -80 -70 0 0 {name=M1
L=0.28u
W=2.75u
body=VGND
nf=4
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
C {gf180mcu_fd_pr/pfet3_03v3.sym} -80 -170 0 0 {name=M2
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
C {gf180mcu_fd_pr/nfet3_03v3.sym} 140 -70 0 0 {name=M3
L=0.28u
W=11.0u
body=VGND
nf=4
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
C {gf180mcu_fd_pr/pfet3_03v3.sym} 140 -170 0 0 {name=M4
L=0.28u
W=20.68u
body=VPWR
nf=4
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
