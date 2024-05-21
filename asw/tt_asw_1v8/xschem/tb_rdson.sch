v {xschem version=3.4.5 file_version=1.2
}
G {}
K {}
V {}
S {}
E {}
N 160 -270 230 -270 {
lab=bus}
N 110 -560 110 -550 {
lab=vdd}
N 110 -490 110 -480 {
lab=GND}
N 160 -310 170 -310 {
lab=vdd}
N 160 -250 170 -250 {
lab=GND}
N 280 120 280 140 {
lab=GND}
N 160 -290 170 -290 {
lab=mod}
N -150 -310 -140 -310 {
lab=vdd}
N 180 -250 180 -230 {
lab=GND}
N 170 -250 180 -250 {
lab=GND}
N 280 30 280 60 {
lab=mod}
N 280 -90 280 -30 {
lab=mod}
N 280 -90 320 -90 {
lab=mod}
N 280 -210 280 -190 {
lab=GND}
N 230 -270 280 -270 {
lab=bus}
N 280 -30 280 30 {
lab=mod}
C {tt_asw_1v8.sym} 10 -280 0 0 {name=x1}
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
dc Vcm 0 1.8 0.01
plot (v(mod) - v(bus)) / 100u
write tb_rdson.raw
*quit 0
.endc
.end
"}
C {devices/vsource.sym} 110 -520 0 0 {name=V1 value=1.8 savecurrent=false}
C {devices/gnd.sym} 110 -480 0 0 {name=l2 lab=GND}
C {devices/lab_pin.sym} 110 -560 2 1 {name=p5 sig_type=std_logic lab=vdd
}
C {devices/lab_pin.sym} 170 -310 2 0 {name=p6 sig_type=std_logic lab=vdd
}
C {devices/gnd.sym} 180 -230 0 0 {name=l3 lab=GND}
C {devices/vsource.sym} 280 90 0 0 {name=Vcm value="1V" savecurrent=false}
C {devices/gnd.sym} 280 140 0 0 {name=l10 lab=GND}
C {devices/lab_pin.sym} 320 -90 0 1 {name=p16 sig_type=std_logic lab=mod}
C {devices/lab_pin.sym} 170 -290 2 0 {name=p1 sig_type=std_logic lab=mod
}
C {devices/isource.sym} 280 -240 0 0 {name=I0 value=100u savecurrent=true}
C {devices/gnd.sym} 280 -190 0 0 {name=l1 lab=GND}
C {devices/lab_pin.sym} -150 -310 2 1 {name=p2 sig_type=std_logic lab=vdd
}
C {devices/lab_wire.sym} 240 -270 0 0 {name=p4 sig_type=std_logic lab=bus}
