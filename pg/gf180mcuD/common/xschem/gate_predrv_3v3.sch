v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N -80 -120 -60 -120 {lab=ctrl}
N -60 -170 -60 -120 {lab=ctrl}
N -60 -170 -40 -170 {lab=ctrl}
N -60 -70 -40 -70 {lab=ctrl}
N -60 -120 -60 -70 {lab=ctrl}
N 0 -40 0 0 {lab=VGND}
N 0 -240 0 -200 {lab=VPWR}
N 0 -140 0 -100 {lab=gate_pre}
N 0 -120 150 -120 {lab=gate_pre}
N -80 -240 0 -240 {lab=VPWR}
N -80 0 0 0 {lab=VGND}
C {devices/title.sym} -340 100 0 0 {name=l1 author="Sylvain Munaut"}
C {devices/iopin.sym} -80 -240 0 1 {name=p2 lab=VPWR sim_pinnumber=2}
C {devices/iopin.sym} -80 0 0 1 {name=p1 lab=VGND sim_pinnumber=1}
C {devices/ipin.sym} -80 -120 0 0 {name=p3 lab=ctrl sim_pinnumber=3}
C {devices/opin.sym} 150 -120 0 0 {name=p4 lab=gate_pre sim_pinnumber=4}
C {gf180mcu_fd_pr/nfet3_03v3.sym} -20 -70 0 0 {name=M1
L=0.28u
W=5.5u
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
C {gf180mcu_fd_pr/pfet3_03v3.sym} -20 -170 0 0 {name=M2
L=0.28u
W=10.34u
body=VPWR
nf=2
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
