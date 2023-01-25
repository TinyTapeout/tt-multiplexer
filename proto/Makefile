IVERILOG ?= iverilog

RTL_SRC=\
	tt_top.v \
	tt_ctrl.v \
	tt_row_mux.v \
	tt_cell_mux4.v \
	tt_user_module.v \
	tt_um_example.v \
	tt_um_test.v \
	$(NULL)

TB_SRC = tt_top_tb.v


tt_top_tb: $(TB_SRC) $(RTL_SRC)
	$(IVERILOG) -o $@ $?

tt_top_tb.vcd:
	./tt_top_tb

tt_user_module.v: tt_user_module.v.mak tt_user_module.yaml 
	./gen_tt_user_module.py

clean:
	rm -f tt_top_tb *.vcd tt_user_module.v
