v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N 80 -20 140 -20 {lab=ctrl}
N 120 20 140 20 {lab=VGND}
N 120 20 120 100 {lab=VGND}
N 100 -40 140 -40 {lab=VDPWR}
N 100 -140 100 -40 {lab=VDPWR}
N 80 -140 100 -140 {lab=VDPWR}
N 120 -60 140 -60 {lab=VAPWR}
N 120 -200 120 -60 {lab=VAPWR}
N 80 -200 120 -200 {lab=VAPWR}
N 80 100 120 100 {lab=VGND}
N 560 -90 560 -40 {lab=H_ctrl_p}
N 560 -90 580 -90 {lab=H_ctrl_p}
N 560 -40 560 10 {lab=H_ctrl_p}
N 560 10 580 10 {lab=H_ctrl_p}
N 810 -40 850 -40 {lab=H_ctrl_n}
N 120 100 620 100 {lab=VGND}
N 620 -60 620 -20 {lab=gate}
N 620 -40 720 -40 {lab=gate}
N 120 -200 690 -200 {lab=VAPWR}
N 750 -200 1100 -200 {lab=GAPWR}
N 1040 -40 1060 -40 {lab=GAPWR}
N 1060 -200 1060 -40 {lab=GAPWR}
N 1040 -20 1060 -20 {lab=VGND}
N 1060 -20 1060 100 {lab=VGND}
N 620 100 1060 100 {lab=VGND}
N 440 -40 460 -40 {lab=H_ctrl_p}
N 440 0 460 0 {lab=H_ctrl_n}
N 460 -40 560 -40 {lab=H_ctrl_p}
N 720 -160 720 -40 {lab=gate}
N 620 40 620 100 {lab=VGND}
N 620 -200 620 -120 {lab=VAPWR}
C {devices/title.sym} 170 190 0 0 {name=l1 author="Sylvain Munaut"}
C {devices/ipin.sym} 80 -20 0 0 {name=p4 lab=ctrl sim_pinnumber=5}
C {devices/iopin.sym} 80 -140 0 1 {name=p2 lab=VDPWR sim_pinnumber=2}
C {devices/iopin.sym} 80 100 0 1 {name=p1 lab=VGND sim_pinnumber=1}
C {devices/iopin.sym} 1100 -200 0 0 {name=p3 lab=GAPWR sim_pinnumber=4}
C {discharge_3v3.sym} 950 -30 0 0 {name=x1}
C {devices/lab_wire.sym} 460 -40 0 1 {name=p5 sig_type=std_logic lab=H_ctrl_p}
C {devices/lab_wire.sym} 460 0 0 1 {name=p6 sig_type=std_logic lab=H_ctrl_n}
C {devices/iopin.sym} 80 -200 0 1 {name=p7 lab=VAPWR sim_pinnumber=3}
C {lv2hv.sym} 290 -20 0 0 {name=x2}
C {devices/lab_wire.sym} 830 -40 0 0 {name=p8 sig_type=std_logic lab=H_ctrl_n}
C {devices/lab_wire.sym} 720 -40 0 1 {name=p9 sig_type=std_logic lab=gate}
C {sg13cmos5l_pr/sg13_hv_pmos3.sym} 720 -180 3 0 {name=M1
l=0.4u
w=3393.0u
body=VAPWR
ng=377
m=1
mm_ok=1
model=sg13_hv_pmos
spiceprefix=X
}
C {sg13cmos5l_pr/sg13_hv_nmos3.sym} 600 10 0 0 {name=M2
l=0.45u
w=8.25u
body=VGND
ng=3
m=1
mm_ok=1
model=sg13_hv_nmos
spiceprefix=X
}
C {sg13cmos5l_pr/sg13_hv_pmos3.sym} 600 -90 0 0 {name=M3
l=0.4u
w=15.15u
body=VAPWR
ng=3
m=1
mm_ok=1
model=sg13_hv_pmos
spiceprefix=X
}
