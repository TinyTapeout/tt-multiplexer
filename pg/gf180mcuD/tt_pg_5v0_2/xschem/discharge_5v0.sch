v {xschem version=3.4.8RC file_version=1.2}
G {}
K {}
V {}
S {}
E {}
N 100 0 400 -0 {lab=VGND}
N 400 -20 400 -0 {lab=VGND}
N 220 -20 220 -0 {lab=VGND}
N 220 -180 220 -160 {lab=#net1}
N 220 -260 220 -240 {lab=#net2}
N 100 -420 400 -420 {lab=GPWR}
N 400 -420 400 -320 {lab=GPWR}
N 220 -420 220 -320 {lab=GPWR}
N 400 -180 400 -160 {lab=#net3}
N 400 -260 400 -240 {lab=#net4}
N 340 -130 360 -130 {lab=gate}
N 100 -380 340 -380 {lab=gate}
N 340 -290 360 -290 {lab=gate}
N 340 -210 360 -210 {lab=gate}
N 160 -130 180 -130 {lab=gate}
N 160 -290 180 -290 {lab=gate}
N 160 -210 180 -210 {lab=gate}
N 340 -380 340 -130 {lab=gate}
N 160 -380 160 -130 {lab=gate}
N 220 -100 220 -80 {lab=#net5}
N 400 -100 400 -80 {lab=#net6}
N 160 -50 180 -50 {lab=gate}
N 160 -130 160 -50 {lab=gate}
N 340 -50 360 -50 {lab=gate}
N 340 -130 340 -50 {lab=gate}
C {devices/title.sym} 180 100 0 0 {name=l1 author="Sylvain Munaut"}
C {devices/iopin.sym} 100 -420 0 1 {name=p2 lab=GPWR sim_pinnumber=2}
C {devices/iopin.sym} 100 0 0 1 {name=p1 lab=VGND sim_pinnumber=1}
C {devices/ipin.sym} 100 -380 0 0 {name=p3 lab=gate sim_pinnumber=3}
C {gf180mcuD_pr/nfet3_05v0.sym} 200 -290 0 0 {name=M1
L=0.80u
W=1.00u
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
C {gf180mcuD_pr/nfet3_05v0.sym} 200 -210 0 0 {name=M2
L=0.80u
W=1.00u
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
C {gf180mcuD_pr/nfet3_05v0.sym} 200 -130 0 0 {name=M3
L=0.80u
W=1.00u
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
C {gf180mcuD_pr/nfet3_05v0.sym} 200 -50 0 0 {name=M4
L=0.80u
W=1.00u
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
C {gf180mcuD_pr/nfet3_05v0.sym} 380 -290 0 0 {name=M5
L=0.80u
W=1.00u
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
C {gf180mcuD_pr/nfet3_05v0.sym} 380 -210 0 0 {name=M6
L=0.80u
W=1.00u
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
C {gf180mcuD_pr/nfet3_05v0.sym} 380 -130 0 0 {name=M7
L=0.80u
W=1.00u
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
C {gf180mcuD_pr/nfet3_05v0.sym} 380 -50 0 0 {name=M8
L=0.80u
W=1.00u
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
