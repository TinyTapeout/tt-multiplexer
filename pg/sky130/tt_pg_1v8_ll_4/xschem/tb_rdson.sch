v {xschem version=3.4.5 file_version=1.2
}
G {}
K {}
V {}
S {}
E {}
N 90 -120 100 -120 {
lab=vdd}
N 80 -370 80 -360 {
lab=vdd}
N 80 -300 80 -290 {
lab=GND}
N 80 -160 100 -160 {
lab=vdd}
N 420 -80 420 -60 {
lab=GND}
N 420 -160 420 -140 {
lab=vdd_dut}
N 400 -160 420 -160 {
lab=vdd_dut}
N 80 -80 80 -60 {
lab=GND}
N 80 -80 100 -80 {
lab=GND}
N 80 -190 80 -120 {
lab=vdd}
N 80 -120 90 -120 {
lab=vdd}
N 90 80 100 80 {
lab=vdd}
N 80 40 100 40 {
lab=vdd}
N 420 120 420 140 {
lab=GND}
N 420 40 420 60 {
lab=vdd_dut_pex}
N 400 40 420 40 {
lab=vdd_dut_pex}
N 80 120 80 140 {
lab=GND}
N 80 120 100 120 {
lab=GND}
N 80 10 80 80 {
lab=vdd}
N 80 80 90 80 {
lab=vdd}
C {tt_pg_1v8_ll_4.sym} 250 -120 0 0 {name=x1}
C {devices/code.sym} 380 -370 0 0 {name=TT_MODELS
only_toplevel=true
format="tcleval( @value )"
value="
** opencircuitdesign pdks install
.lib $::SKYWATER_MODELS/sky130.lib.spice tt
.include $::SKYWATER_STDCELLS/sky130_fd_sc_hd.spice


"
spice_ignore=false}
C {devices/code.sym} 220 -370 0 0 {name=SIMULATION
only_toplevel=false 
value="
.param mc_mm_switch=0
.control
save all
dc V1 1.6 2.0 0.01
plot ((v(vdd) - v(vdd_dut)) / 1m) ((v(vdd) - v(vdd_dut_pex)) / 1m) 
write tb_rdson.raw
*quit 0
.endc
.end
"}
C {devices/gnd.sym} 80 -60 0 0 {name=l3 lab=GND}
C {devices/isource.sym} 420 -110 0 0 {name=I0 value=1m savecurrent=true}
C {devices/gnd.sym} 420 -60 0 0 {name=l1 lab=GND}
C {devices/vsource.sym} 80 -330 0 0 {name=V1 value=1.8 savecurrent=false}
C {devices/gnd.sym} 80 -290 0 0 {name=l5 lab=GND}
C {devices/lab_pin.sym} 80 -370 2 1 {name=p8 sig_type=std_logic lab=vdd
}
C {devices/lab_pin.sym} 80 -190 2 1 {name=p4 sig_type=std_logic lab=vdd
}
C {devices/lab_pin.sym} 420 -160 0 1 {name=p1 sig_type=std_logic lab=vdd_dut

}
C {tt_pg_1v8_ll_4.sym} 250 80 0 0 {name=x2
schematic=tt_pg_1v8_ll_4_pex.sim
spice_sym_def="tcleval(.include [file normalize ../mag/tt_pg_1v8_ll_4.pex.spice])"
tclcommand="textwindow [file normalize ../mag/tt_pg_1v8.pex.spice]"}
C {devices/gnd.sym} 80 140 0 0 {name=l2 lab=GND}
C {devices/isource.sym} 420 90 0 0 {name=I1 value=1m savecurrent=true}
C {devices/gnd.sym} 420 140 0 0 {name=l4 lab=GND}
C {devices/lab_pin.sym} 80 10 2 1 {name=p2 sig_type=std_logic lab=vdd
}
C {devices/lab_pin.sym} 420 40 0 1 {name=p3 sig_type=std_logic lab=vdd_dut_pex

}
