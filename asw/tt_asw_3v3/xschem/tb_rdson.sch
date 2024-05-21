v {xschem version=3.4.5 file_version=1.2
}
G {}
K {}
V {}
S {}
E {}
N 160 -260 230 -260 {
lab=bus}
N -100 -560 -100 -550 {
lab=vcc}
N -100 -490 -100 -480 {
lab=GND}
N 160 -300 170 -300 {
lab=vdd}
N 320 -180 320 -160 {
lab=GND}
N -150 -320 -140 -320 {
lab=ctrl}
N 240 -180 240 -160 {
lab=GND}
N 10 -490 10 -480 {
lab=GND}
N 10 -560 10 -550 {
lab=ctrl}
N 160 -320 170 -320 {
lab=vcc}
N -190 -560 -190 -550 {
lab=vdd}
N -190 -490 -190 -480 {
lab=GND}
N 160 -240 180 -240 {
lab=GND}
N 180 -240 180 -220 {
lab=GND}
N 180 -220 180 -160 {
lab=GND}
N 230 -260 240 -260 {
lab=bus}
N 240 -260 240 -240 {
lab=bus}
N 160 -280 320 -280 {
lab=mod}
N 320 -280 320 -240 {
lab=mod}
N 160 -10 230 -10 {
lab=bus_pex}
N 160 -50 170 -50 {
lab=vdd}
N -150 -70 -140 -70 {
lab=ctrl}
N 240 70 240 90 {
lab=GND}
N 160 -70 170 -70 {
lab=vcc}
N 160 10 180 10 {
lab=GND}
N 180 10 180 30 {
lab=GND}
N 180 30 180 90 {
lab=GND}
N 230 -10 240 -10 {
lab=bus_pex}
N 240 -10 240 10 {
lab=bus_pex}
N 160 -30 320 -30 {
lab=mod}
C {tt_asw_3v3.sym} 10 -280 0 0 {name=x1}
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
tran 10p 100n
plot ctrl x1.tgon x1.tgon_n
dc Vcm 0 3.3 0.01
plot ((v(mod) - v(bus)) / 100u) ((v(mod) - v(bus_pex)) / 100u)
write tb_rdson.raw
*quit 0
.endc
.end
"}
C {devices/vsource.sym} -100 -520 0 0 {name=V2 value=3.3 savecurrent=false}
C {devices/gnd.sym} -100 -480 0 0 {name=l2 lab=GND}
C {devices/lab_pin.sym} -100 -560 2 1 {name=p5 sig_type=std_logic lab=vcc
}
C {devices/lab_pin.sym} 170 -300 2 0 {name=p6 sig_type=std_logic lab=vdd
}
C {devices/gnd.sym} 180 -160 0 0 {name=l3 lab=GND}
C {devices/vsource.sym} 320 -210 0 0 {name=Vcm value="1V" savecurrent=false}
C {devices/gnd.sym} 320 -160 0 0 {name=l10 lab=GND}
C {devices/isource.sym} 240 -210 0 0 {name=I0 value=100u savecurrent=true}
C {devices/gnd.sym} 240 -160 0 0 {name=l1 lab=GND}
C {devices/lab_pin.sym} -150 -320 2 1 {name=p2 sig_type=std_logic lab=ctrl
}
C {devices/lab_wire.sym} 240 -260 0 1 {name=p4 sig_type=std_logic lab=bus}
C {devices/vsource.sym} 10 -520 0 0 {name=V3 value="PULSE(1.8 0 5n 0 0 10n 20n)" savecurrent=false}
C {devices/gnd.sym} 10 -480 0 0 {name=l4 lab=GND}
C {devices/lab_pin.sym} 10 -560 2 1 {name=p3 sig_type=std_logic lab=ctrl
}
C {devices/lab_pin.sym} 170 -320 2 0 {name=p7 sig_type=std_logic lab=vcc
}
C {devices/vsource.sym} -190 -520 0 0 {name=V1 value=1.8 savecurrent=false}
C {devices/gnd.sym} -190 -480 0 0 {name=l5 lab=GND}
C {devices/lab_pin.sym} -190 -560 2 1 {name=p8 sig_type=std_logic lab=vdd
}
C {devices/lab_wire.sym} 320 -280 0 1 {name=p1 sig_type=std_logic lab=mod}
C {tt_asw_3v3.sym} 10 -30 0 0 {name=x2
schematic=tt_asw_3v3_pex.sim
spice_sym_def="tcleval(.include [file normalize ../mag/tt_asw_3v3.pex.spice])"
tclcommand="textwindow [file normalize ../mag/tt_asw_3v3.pex.spice]"}
C {devices/lab_pin.sym} 170 -50 2 0 {name=p9 sig_type=std_logic lab=vdd
}
C {devices/gnd.sym} 180 90 0 0 {name=l6 lab=GND}
C {devices/isource.sym} 240 40 0 0 {name=I1 value=100u savecurrent=true}
C {devices/gnd.sym} 240 90 0 0 {name=l8 lab=GND}
C {devices/lab_pin.sym} -150 -70 2 1 {name=p10 sig_type=std_logic lab=ctrl
}
C {devices/lab_wire.sym} 240 -10 0 1 {name=p11 sig_type=std_logic lab=bus_pex}
C {devices/lab_pin.sym} 170 -70 2 0 {name=p12 sig_type=std_logic lab=vcc
}
C {devices/lab_wire.sym} 320 -30 0 1 {name=p13 sig_type=std_logic lab=mod}
