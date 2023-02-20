IVERILOG ?= iverilog

RTL_SRC=\
	tt_top.v \
	tt_ctrl.v \
	tt_row_mux.v \
	tt_user_module.v \
	tt_um_example.v \
	tt_um_test.v \
	$(NULL)

TECH ?= generic
PRIM_SRC=$(addprefix prim_$(TECH)/, \
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

TB_SRC = tt_top_tb.v

tt_top_tb: $(TB_SRC) $(RTL_SRC) $(PRIM_SRC)
	$(IVERILOG) $(DEFS) -Wall -Wno-timescale -o $@ $^

tt_top_tb.vcd:
	./tt_top_tb

tt_user_module.v: tt_user_module.v.mak tt_user_module.yaml 
	./gen_tt_user_module.py

clean:
	rm -f tt_top_tb *.vcd tt_user_module.v
