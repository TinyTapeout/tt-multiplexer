v {xschem version=3.4.5 file_version=1.2
}
G {}
K {}
V {}
S {}
E {}
T {125p Max capacitance of 8x2 tile filled
with decap cells} 130 -180 0 0 0.2 0.2 {}
N -100 -560 -100 -550 {
lab=vcc}
N -100 -490 -100 -480 {
lab=GND}
N -150 -280 -140 -280 {
lab=ctrl}
N 10 -490 10 -480 {
lab=GND}
N 10 -560 10 -550 {
lab=ctrl}
N -190 -560 -190 -550 {
lab=vdd}
N -190 -490 -190 -480 {
lab=GND}
N -160 -280 -150 -280 {
lab=ctrl}
N -160 -320 -140 -320 {
lab=vcc}
N -160 -300 -140 -300 {
lab=vdd}
N 180 -240 180 -220 {
lab=GND}
N 180 -320 180 -300 {
lab=vcc_dut}
N 160 -320 180 -320 {
lab=vcc_dut}
N -160 -240 -160 -220 {
lab=GND}
N -160 -240 -140 -240 {
lab=GND}
N 180 -320 260 -320 {
lab=vcc_dut}
C {tt_pg_3v3_2.sym} 10 -280 0 0 {name=x1}
C {devices/code.sym} 350 -560 0 0 {name=TT_MODELS
only_toplevel=true
format="tcleval( @value )"
value="
** opencircuitdesign pdks install
.lib $::SKYWATER_MODELS/sky130.lib.spice tt
.include $::SKYWATER_STDCELLS/sky130_fd_sc_hd.spice


"
spice_ignore=false}
C {devices/code.sym} 190 -560 0 0 {name=SIMULATION
only_toplevel=false 
value="
.param mc_mm_switch=0
.control
save all
tran 100p 5u
plot ctrl x1.H_ctrl x1.H_ctrl_n x1.pmos_gate vcc_dut xlimit 9n 20n
plot ctrl x1.H_ctrl x1.H_ctrl_n x1.pmos_gate vcc_dut xlimit 209n 220n
plot vcc_dut
plot i(v.x1.vdischg)
*quit 0
.endc
.end
"}
C {devices/vsource.sym} -100 -520 0 0 {name=V2 value=3.3 savecurrent=true}
C {devices/gnd.sym} -100 -480 0 0 {name=l2 lab=GND}
C {devices/lab_pin.sym} -100 -560 2 1 {name=p5 sig_type=std_logic lab=vcc
}
C {devices/gnd.sym} -160 -220 0 0 {name=l3 lab=GND}
C {devices/gnd.sym} 180 -220 0 0 {name=l1 lab=GND}
C {devices/lab_pin.sym} -160 -280 2 1 {name=p2 sig_type=std_logic lab=ctrl
}
C {devices/vsource.sym} 10 -520 0 0 {name=V3 value="PULSE(0 1.8 10n 0.5n 0.5n 200n 10u)" savecurrent=false}
C {devices/gnd.sym} 10 -480 0 0 {name=l4 lab=GND}
C {devices/lab_pin.sym} 10 -560 2 1 {name=p3 sig_type=std_logic lab=ctrl
}
C {devices/vsource.sym} -190 -520 0 0 {name=V1 value=1.8 savecurrent=true}
C {devices/gnd.sym} -190 -480 0 0 {name=l5 lab=GND}
C {devices/lab_pin.sym} -190 -560 2 1 {name=p8 sig_type=std_logic lab=vdd
}
C {devices/lab_pin.sym} -160 -300 2 1 {name=p4 sig_type=std_logic lab=vdd
}
C {devices/lab_pin.sym} -160 -320 2 1 {name=p6 sig_type=std_logic lab=vcc
}
C {devices/lab_pin.sym} 260 -320 0 1 {name=p1 sig_type=std_logic lab=vcc_dut

}
C {devices/capa.sym} 180 -270 0 0 {name=C1
m=1
value=125p
footprint=1206
device="ceramic capacitor"}
