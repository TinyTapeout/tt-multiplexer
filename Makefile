#
# tt-multiplex build
#

# Configs
TECH ?= generic
SIM_DEFS += -DSIM

# Binaries
IVERILOG ?= iverilog
SBY ?= sby

# Sources
RTL_SRC=$(addprefix rtl/, \
	tt_top.v \
	tt_ctrl.v \
	tt_mux.v \
)

RTL_INC=$(addprefix rtl/, \
	tt_defs.vh \
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
	tt_prim_mux2.v \
	tt_prim_mux4.v \
	tt_prim_tbuf_pol.v \
	tt_prim_tbuf.v \
	tt_prim_tie.v \
	tt_prim_zbuf.v \
)

ifeq ($(TECH),sky130)
SIM_SRC += $(addprefix sim/sky130/, \
	sky130_fd_sc_hd.v \
	primitives.v \
)
SIM_DEFS += -DWITH_POWER=1 -DUSE_POWER_PINS=1 -DFUNCTIONAL=1 -DUNIT_DELAY=\#1
endif

all: sim

# Generated sources
gensrc: rtl/tt_defs.vh cfg/modules_placed.yaml rtl/tt_user_module.v

rtl/tt_defs.vh: rtl/tt_defs.vh.mak
	./py/gen_tt_defs.py $^ > $@

cfg/modules_placed.yaml: cfg/modules.yaml
	./py/place_modules.py $^ $@

rtl/tt_user_module.v: rtl/tt_user_module.v.mak cfg/modules_placed.yaml
	./py/gen_tt_user_module.py $^ > $@

# Simulation targets
sim: sim/tt_top_tb.vcd

sim/tt_top_tb: $(SIM_SRC) $(RTL_SRC) $(RTL_INC) $(PRIM_SRC) 
	$(IVERILOG) $(SIM_DEFS) -Wall -Wno-timescale -Irtl -o $@ $(SIM_SRC) $(RTL_SRC) $(PRIM_SRC)

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

formal_%: formal/tt_user_module_%.v $(RTL_SRC) $(RTL_INC)
	cd formal && sby -f tt_$*.sby

# Cleanup
clean:
	rm -f \
		cfg/modules_placed.yaml \
		rtl/tt_defs.vh \
		rtl/tt_user_module.v \
		sim/tt_top_tb \
		sim/*.vcd \
		sim/tt_user_module.v \
		formal/modules_*.{yaml,v} \
		formal/*.vcd \
		$(NULL)
	rm -Rf formal/tt_tristate
	rm -Rf formal/tt_connectivity

# Makefile things
.PHONY: gensrc sim clean
