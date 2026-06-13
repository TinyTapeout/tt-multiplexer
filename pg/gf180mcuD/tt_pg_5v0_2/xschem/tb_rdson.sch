v {xschem version=3.4.8RC file_version=1.2}
G {}
K {}
V {}
S {}
E {}
N 20 -370 20 -360 {
lab=VDPWR}
N 20 -300 20 -290 {
lab=GND}
N 420 -80 420 -60 {
lab=GND}
N 420 -160 420 -140 {
lab=vapwr_dut}
N 400 -160 420 -160 {
lab=vapwr_dut}
N 80 -100 80 -80 {
lab=GND}
N 80 -100 100 -100 {
lab=GND}
N 40 -190 40 -120 {
lab=VDPWR}
N 90 80 100 80 {
lab=VDPWR}
N 420 120 420 140 {
lab=GND}
N 420 40 420 60 {
lab=vapwr_dut_pex}
N 400 40 420 40 {
lab=vapwr_dut_pex}
N 80 100 80 120 {
lab=GND}
N 80 100 100 100 {
lab=GND}
N 140 -370 140 -360 {
lab=VAPWR}
N 140 -300 140 -290 {
lab=GND}
N 40 -120 100 -120 {lab=VDPWR}
N 40 -140 100 -140 {lab=VDPWR}
N 40 10 40 80 {
lab=VDPWR}
N 40 80 100 80 {lab=VDPWR}
N 40 60 100 60 {lab=VDPWR}
N 80 40 100 40 {lab=VAPWR}
N 80 -20 80 40 {lab=VAPWR}
N 80 -160 100 -160 {lab=VAPWR}
N 80 -220 80 -160 {lab=VAPWR}
C {tt_pg_5v0_2.sym} 250 -130 0 0 {name=x1}
C {devices/code.sym} 380 -370 0 0 {name=TT_MODELS
only_toplevel=true
format="tcleval( @value )"
value="
.include design.ngspice
.lib sm141064.ngspice typical
"
spice_ignore=false}
C {devices/code.sym} 220 -370 0 0 {name=SIMULATION
only_toplevel=false 
value="
.control
save all
dc V2 3.0 5.5 0.05
plot ((v(VAPWR) - v(vapwr_dut)) / 1m) ((v(VAPWR) - v(vapwr_dut_pex)) / 1m) 
write tb_rdson.raw
*quit 0
.endc
.end
"}
C {devices/gnd.sym} 80 -80 0 0 {name=l3 lab=GND}
C {devices/isource.sym} 420 -110 0 0 {name=I0 value=1m savecurrent=true}
C {devices/gnd.sym} 420 -60 0 0 {name=l1 lab=GND}
C {devices/vsource.sym} 20 -330 0 0 {name=V1 value=3.3 savecurrent=false}
C {devices/gnd.sym} 20 -290 0 0 {name=l5 lab=GND}
C {devices/lab_pin.sym} 20 -370 2 1 {name=p8 sig_type=std_logic lab=VDPWR
}
C {devices/lab_pin.sym} 40 -190 2 1 {name=p4 sig_type=std_logic lab=VDPWR
}
C {devices/lab_pin.sym} 420 -160 0 1 {name=p1 sig_type=std_logic lab=vapwr_dut

}
C {tt_pg_5v0_2.sym} 250 70 0 0 {name=x2
schematic=tt_pg_5v0_2_pex.sim
spice_sym_def="tcleval(.include [file normalize ../mag/tt_pg_5v0_2.pex.spice])"
tclcommand="textwindow [file normalize ../mag/tt_pg_5v0_2.pex.spice]"}
C {devices/gnd.sym} 80 120 0 0 {name=l2 lab=GND}
C {devices/isource.sym} 420 90 0 0 {name=I1 value=1m savecurrent=true}
C {devices/gnd.sym} 420 140 0 0 {name=l4 lab=GND}
C {devices/lab_pin.sym} 420 40 0 1 {name=p3 sig_type=std_logic lab=vapwr_dut_pex

}
C {devices/vsource.sym} 140 -330 0 0 {name=V2 value=3.3 savecurrent=false}
C {devices/gnd.sym} 140 -290 0 0 {name=l6 lab=GND}
C {devices/lab_pin.sym} 140 -370 2 1 {name=p5 sig_type=std_logic lab=VAPWR
}
C {devices/lab_pin.sym} 40 10 2 1 {name=p2 sig_type=std_logic lab=VDPWR
}
C {devices/lab_pin.sym} 80 -20 2 1 {name=p6 sig_type=std_logic lab=VAPWR
}
C {devices/lab_pin.sym} 80 -220 2 1 {name=p7 sig_type=std_logic lab=VAPWR
}
