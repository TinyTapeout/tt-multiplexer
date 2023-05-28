#
# tt-multiplex build
#

# Configs
TECH ?= generic

# Binaries
IVERILOG ?= iverilog
SBY ?= sby

# Sources
RTL_SRC=$(addprefix rtl/, \
	tt_top.v \
	tt_ctrl.v \
	tt_mux.v \
)

SIM_SRC=$(addprefix sim/, \
	tt_top_tb.v \
	tt_user_module.v \
	tt_um_test.v \
)

PRIM_SRC=$(addprefix rtl/prim_$(TECH)/, \
	tt_prim_buf.v \
	tt_prim_dfrbp.v \
	tt_prim_diode.v \
	tt_prim_inv.v \
	tt_prim_mux4.v \
	tt_prim_tbuf_pol.v \
	tt_prim_tbuf.v \
	tt_prim_zbuf.v \
)

ifeq ($(TECH),sky130)
PRIM_SRC += $(addprefix prim_sky130/sim/, \
	sky130_fd_sc_hd.v \
	primitives.v \
)
DEFS += -DWITH_POWER=1 -DUSE_POWER_PINS=1 -DFUNCTIONAL=1 -DUNIT_DELAY=\#1
endif


# Simulation targets
sim: sim/tt_top_tb.vcd

sim/tt_top_tb: $(SIM_SRC) $(RTL_SRC) $(PRIM_SRC)
	$(IVERILOG) $(DEFS) -Wall -Wno-timescale -o $@ $^

sim/tt_top_tb.vcd: sim/tt_top_tb
	cd sim && ./tt_top_tb

sim/tt_user_module.v: rtl/tt_user_module.v.mak sim/modules_sim.yaml
	./py/gen_tt_user_module.py $^ > $@

# Formal targets
formal/modules_tristate.yaml:
	./py/gen_formal.py --module test > $@

formal/modules_connectivity.yaml:
	./py/gen_formal.py --module formal > $@

formal/tt_user_module_%.v: rtl/tt_user_module.v.mak formal/modules_%.yaml
	./py/gen_tt_user_module.py $^ > $@

formal_%: formal/tt_user_module_%.v
	cd formal && sby -f tt_$*.sby

# Cleanup
clean:
	rm -f \
		sim/tt_top_tb \
		sim/*.vcd \
		sim/tt_user_module.v \
		formal/modules_*.{yaml,v} \
		formal/*.vcd \
		$(NULL)
	rm -Rf formal/tt_tristate
	rm -Rf formal/tt_connectivity
