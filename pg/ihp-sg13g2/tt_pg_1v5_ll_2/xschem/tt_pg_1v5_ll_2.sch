v {xschem version=3.4.8RC file_version=1.2}
G {}
K {}
V {}
S {}
E {}
N 80 100 270 100 {lab=VGND}
N 100 10 100 100 {lab=VGND}
N 260 -20 280 -20 {lab=ctrl}
N 280 -70 280 -20 {lab=ctrl}
N 280 -70 300 -70 {lab=ctrl}
N 280 30 300 30 {lab=ctrl}
N 280 -20 280 30 {lab=ctrl}
N 340 60 340 100 {lab=VGND}
N 270 100 340 100 {lab=VGND}
N 80 -140 340 -140 {lab=VPWR}
N 340 -140 340 -100 {lab=VPWR}
N 100 -140 100 -50 {lab=VPWR}
N 340 -40 340 -0 {lab=ctrl_n}
N 340 -140 460 -140 {lab=VPWR}
N 340 -20 490 -20 {lab=ctrl_n}
N 490 -100 490 -20 {lab=ctrl_n}
N 490 -20 520 -20 {lab=ctrl_n}
N 340 100 820 100 {lab=VGND}
N 710 0 730 0 {lab=VGND}
N 730 0 730 100 {lab=VGND}
N 820 20 820 100 {lab=VGND}
N 520 -140 860 -140 {lab=GPWR}
N 710 -20 730 -20 {lab=GPWR}
N 730 -140 730 -20 {lab=GPWR}
N 820 -140 820 -40 {lab=GPWR}
C {devices/title.sym} 170 190 0 0 {name=l1 author="Sylvain Munaut"}
C {devices/ipin.sym} 260 -20 0 0 {name=p4 lab=ctrl sim_pinnumber=4}
C {devices/iopin.sym} 80 -140 0 1 {name=p2 lab=VPWR sim_pinnumber=2}
C {devices/iopin.sym} 80 100 0 1 {name=p1 lab=VGND sim_pinnumber=1}
C {devices/iopin.sym} 860 -140 0 0 {name=p3 lab=GPWR sim_pinnumber=3}
C {sg13g2_pr/sg13_lv_nmos3.sym} 320 30 0 0 {name=M1
l=0.13u
w=5.2u
body=VGND
ng=2
m=1
model=sg13_lv_nmos
spiceprefix=X
}
C {sg13g2_pr/sg13_lv_pmos3.sym} 320 -70 0 0 {name=M2
l=0.13u
w=8.88u
body=VPWR
ng=2
m=1
model=sg13_lv_pmos
spiceprefix=X}
C {sg13g2_pr/sg13_lv_pmos3.sym} 490 -120 3 0 {name=M3
l=0.2u
w=3922.5u
body=VPWR
ng=523
m=1
model=sg13_lv_pmos
spiceprefix=X
}
C {sg13g2_pr/cap_cmim.sym} 100 -20 0 0 {name=C1
model=cap_cmim
w=6.3e-6
l=43.36e-6
m=4
spiceprefix=X}
C {sg13g2_pr/cap_cmim.sym} 820 -10 0 0 {name=C2
model=cap_cmim
w=6.3e-6
l=34.82e-6
m=3
spiceprefix=X}
C {dischg.sym} 620 -10 0 0 {name=x1[1:0]}
C {devices/lab_wire.sym} 470 -20 0 0 {name=p5 sig_type=std_logic lab=ctrl_n}
