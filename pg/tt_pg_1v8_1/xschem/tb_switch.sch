v {xschem version=3.4.5 file_version=1.2
}
G {}
K {}
V {}
S {}
E {}
T {Max capacitance of 8x1 area
filled with decap cells} 480 -120 0 0 0.2 0.2 {}
N 90 -120 100 -120 {
lab=#net1}
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
N 80 -120 90 -120 {
lab=#net1}
N 80 -190 80 -160 {
lab=vdd}
N -40 -120 80 -120 {
lab=#net1}
C {tt_pg_1v8_1.sym} 250 -120 0 0 {name=x1}
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
tran 50p 5u
plot vdd_dut
plot vdd_dut x1.ctrl_n xlimit 50n 60n
*quit 0
.endc
.end
"}
C {devices/gnd.sym} 80 -60 0 0 {name=l3 lab=GND}
C {devices/gnd.sym} 420 -60 0 0 {name=l1 lab=GND}
C {devices/vsource.sym} 80 -330 0 0 {name=V1 value=1.8 savecurrent=true}
C {devices/gnd.sym} 80 -290 0 0 {name=l5 lab=GND}
C {devices/lab_pin.sym} 80 -370 2 1 {name=p8 sig_type=std_logic lab=vdd
}
C {devices/lab_pin.sym} 80 -190 2 1 {name=p4 sig_type=std_logic lab=vdd
}
C {devices/lab_pin.sym} 420 -160 0 1 {name=p1 sig_type=std_logic lab=vdd_dut

}
C {devices/capa.sym} 420 -110 0 0 {name=C1
m=1
value=62.5p
footprint=1206
device="ceramic capacitor"}
C {devices/vsource.sym} -40 -90 0 1 {name=V2 value="PULSE(0 1.8 50n 0.5n 0.5n 99.5n 4u)" savecurrent=false}
C {devices/gnd.sym} -40 -60 0 0 {name=l2 lab=GND}
