v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N 300 -100 300 -20 {lab=gate[1:3]}
N 300 -20 330 -20 {lab=gate[1:3]}
N 520 0 540 0 {lab=VGND}
N 540 0 540 100 {lab=VGND}
N 520 -20 540 -20 {lab=GPWR}
N 540 -140 540 -20 {lab=GPWR}
N -560 -20 -520 -20 {lab=ctrl}
N -540 -40 -520 -40 {lab=VPWR}
N -540 -140 -540 -40 {lab=VPWR}
N -540 0 -540 100 {lab=VGND}
N -540 0 -520 0 {lab=VGND}
N -560 -140 -540 -140 {lab=VPWR}
N -560 100 -540 100 {lab=VGND}
N -220 -20 -120 -20 {lab=gate_pre}
N -140 -40 -120 -40 {lab=VPWR}
N -140 -140 -140 -40 {lab=VPWR}
N -540 -140 -140 -140 {lab=VPWR}
N -140 0 -120 0 {lab=VGND}
N -140 0 -140 100 {lab=VGND}
N -540 100 -140 100 {lab=VGND}
N 180 -20 300 -20 {lab=gate[1:3]}
N -140 -140 270 -140 {lab=VPWR}
N 540 -140 600 -140 {lab=GPWR}
N 330 -140 540 -140 {lab=GPWR}
N -140 100 540 100 {lab=VGND}
C {devices/title.sym} -430 190 0 0 {name=l1 author="Sylvain Munaut"}
C {devices/ipin.sym} -560 -20 0 0 {name=p4 lab=ctrl sim_pinnumber=4}
C {devices/iopin.sym} -560 -140 0 1 {name=p2 lab=VPWR sim_pinnumber=2}
C {devices/iopin.sym} -560 100 0 1 {name=p1 lab=VGND sim_pinnumber=1}
C {devices/iopin.sym} 600 -140 0 0 {name=p3 lab=GPWR sim_pinnumber=3}
C {discharge_3v3.sym} 430 -10 0 0 {name=x[1:3]}
C {devices/lab_wire.sym} -140 -20 0 0 {name=p5 sig_type=std_logic lab=gate_pre}
C {gf180mcu_fd_pr/pfet3_03v3.sym} 300 -120 3 0 {name=M1[1:3]
L=0.28u
W=3901.5u
body=VPWR
nf=459
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
C {gate_predrv_3v3.sym} -370 -20 0 0 {name=x1}
C {gate_drv_3v3.sym} 30 -20 0 0 {name=x2[1:3]}
C {devices/lab_wire.sym} 260 -20 0 0 {name=p6 sig_type=std_logic lab=gate[1:3]}
