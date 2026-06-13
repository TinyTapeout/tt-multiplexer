v {xschem version=3.4.8RC file_version=1.2}
G {}
K {}
V {}
S {}
E {}
T {Rough estimate of max capacitance} 560 -120 0 0 0.2 0.2 {}
N 90 -120 100 -120 {
lab=ctrl}
N -20 -360 -20 -350 {
lab=VDPWR}
N -20 -290 -20 -280 {
lab=GND}
N 20 -140 40 -140 {
lab=VDPWR}
N 500 -80 500 -60 {
lab=GND}
N 500 -160 500 -140 {
lab=vapwr_dut}
N 480 -160 500 -160 {
lab=vapwr_dut}
N 80 -120 90 -120 {
lab=ctrl}
N 20 -170 20 -140 {
lab=VDPWR}
N -40 -120 80 -120 {
lab=ctrl}
N 400 -160 420 -160 {lab=#net1}
N -40 -120 -40 -100 {lab=ctrl}
N 80 -100 80 -40 {lab=GND}
N 80 -100 100 -100 {lab=GND}
N 40 -140 100 -140 {lab=VDPWR}
N 80 -160 100 -160 {lab=VAPWR}
N 80 -200 80 -160 {lab=VAPWR}
N 100 -360 100 -350 {
lab=VAPWR}
N 100 -290 100 -280 {
lab=GND}
C {devices/code.sym} 220 -370 0 0 {name=SIMULATION
only_toplevel=false 
value="
.param mc_mm_switch=0
.control
save all
tran 50p 5u
plot vapwr_dut
plot vapwr_dut ctrl+5 x1.H_ctrl_n+10 x1.H_ctrl_p+10 xlimit 50n 60n
*quit 0
.endc
.end
"}
C {devices/gnd.sym} 80 -40 0 0 {name=l3 lab=GND}
C {devices/gnd.sym} 500 -60 0 0 {name=l1 lab=GND}
C {devices/vsource.sym} -20 -320 0 0 {name=V1 value=3.3 savecurrent=true}
C {devices/gnd.sym} -20 -280 0 0 {name=l5 lab=GND}
C {devices/lab_pin.sym} -20 -360 2 1 {name=p8 sig_type=std_logic lab=VDPWR
}
C {devices/lab_pin.sym} 20 -170 2 1 {name=p4 sig_type=std_logic lab=VDPWR
}
C {devices/lab_pin.sym} 500 -160 0 1 {name=p1 sig_type=std_logic lab=vapwr_dut

}
C {devices/capa.sym} 500 -110 0 0 {name=C1
m=1
value=75p
footprint=1206
device="ceramic capacitor"}
C {devices/vsource.sym} -40 -70 0 1 {name=V2 value="PULSE(0 3.3 50n 0.5n 0.5n 99.5n 4u)" savecurrent=false}
C {devices/gnd.sym} -40 -40 0 0 {name=l2 lab=GND}
C {devices/ammeter.sym} 450 -160 3 0 {name=Vdut savecurrent=true spice_ignore=0 lvs_ignore=1}
C {devices/code.sym} 390 -370 0 0 {name=TT_MODELS
only_toplevel=true
format="tcleval( @value )"
value="
.include design.ngspice
.lib sm141064.ngspice typical
"
spice_ignore=false}
C {tt_pg_5v0_2.sym} 250 -130 0 0 {name=x1}
C {devices/vsource.sym} 100 -320 0 0 {name=V3 value=5 savecurrent=true}
C {devices/gnd.sym} 100 -280 0 0 {name=l4 lab=GND}
C {devices/lab_pin.sym} 100 -360 2 1 {name=p2 sig_type=std_logic lab=VAPWR
}
C {devices/lab_pin.sym} -40 -120 2 1 {name=p3 sig_type=std_logic lab=ctrl
}
C {devices/lab_pin.sym} 80 -200 2 1 {name=p5 sig_type=std_logic lab=VAPWR
}
