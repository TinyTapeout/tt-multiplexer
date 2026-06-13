v {xschem version=3.4.8RC file_version=1.2}
G {}
K {}
V {}
S {}
E {}
N -60 0 -30 0 {lab=ASIG5V}
N 30 -0 60 -0 {lab=xxx}
C {devices/res.sym} 0 0 1 0 {name=R1
value=0
footprint=1206
device=resistor
m=1}
C {devices/iopin.sym} 60 0 0 0 {name=p1 lab=analog}
C {devices/iopin.sym} -60 0 2 0 {name=p2 lab=ASIG5V}
