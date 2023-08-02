/*
 * tt_um_tpl.v
 *
 * Dummy user module template used as a STA standin
 *
 * Copyright (c) 2023 Sylvain Munaut <tnt@246tNt.com>
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module {mod_name} (
	input  wire VGND,
    input  wire VPWR,
	inout  wire [7:0] ua,
	input  wire [7:0] ui_in,
	output wire [7:0] uo_out,
	input  wire [7:0] uio_in,
	output wire [7:0] uio_out,
	output wire [7:0] uio_oe,
	input  wire       ena,
	input  wire       clk,
	input  wire       rst_n
);

	sky130_fd_sc_hd__clkbuf_2 buf_in_ui_in_0 (
		.VGND (VGND),
		.VNB  (VGND),
		.VPB  (VPWR),
		.VPWR (VPWR),
		.A    (ui_in[0]),
		.X    ()
	);

	sky130_fd_sc_hd__clkbuf_2 buf_in_ui_in_1 (
		.VGND (VGND),
		.VNB  (VGND),
		.VPB  (VPWR),
		.VPWR (VPWR),
		.A    (ui_in[1]),
		.X    ()
	);

	sky130_fd_sc_hd__clkbuf_2 buf_in_ui_in_2 (
		.VGND (VGND),
		.VNB  (VGND),
		.VPB  (VPWR),
		.VPWR (VPWR),
		.A    (ui_in[2]),
		.X    ()
	);

	sky130_fd_sc_hd__clkbuf_2 buf_in_ui_in_3 (
		.VGND (VGND),
		.VNB  (VGND),
		.VPB  (VPWR),
		.VPWR (VPWR),
		.A    (ui_in[3]),
		.X    ()
	);

	sky130_fd_sc_hd__clkbuf_2 buf_in_ui_in_4 (
		.VGND (VGND),
		.VNB  (VGND),
		.VPB  (VPWR),
		.VPWR (VPWR),
		.A    (ui_in[4]),
		.X    ()
	);

	sky130_fd_sc_hd__clkbuf_2 buf_in_ui_in_5 (
		.VGND (VGND),
		.VNB  (VGND),
		.VPB  (VPWR),
		.VPWR (VPWR),
		.A    (ui_in[5]),
		.X    ()
	);

	sky130_fd_sc_hd__clkbuf_2 buf_in_ui_in_6 (
		.VGND (VGND),
		.VNB  (VGND),
		.VPB  (VPWR),
		.VPWR (VPWR),
		.A    (ui_in[6]),
		.X    ()
	);

	sky130_fd_sc_hd__clkbuf_2 buf_in_ui_in_7 (
		.VGND (VGND),
		.VNB  (VGND),
		.VPB  (VPWR),
		.VPWR (VPWR),
		.A    (ui_in[7]),
		.X    ()
	);

	sky130_fd_sc_hd__clkbuf_2 buf_in_uio_in_0 (
		.VGND (VGND),
		.VNB  (VGND),
		.VPB  (VPWR),
		.VPWR (VPWR),
		.A    (uio_in[0]),
		.X    ()
	);

	sky130_fd_sc_hd__clkbuf_2 buf_in_uio_in_1 (
		.VGND (VGND),
		.VNB  (VGND),
		.VPB  (VPWR),
		.VPWR (VPWR),
		.A    (uio_in[1]),
		.X    ()
	);

	sky130_fd_sc_hd__clkbuf_2 buf_in_uio_in_2 (
		.VGND (VGND),
		.VNB  (VGND),
		.VPB  (VPWR),
		.VPWR (VPWR),
		.A    (uio_in[2]),
		.X    ()
	);

	sky130_fd_sc_hd__clkbuf_2 buf_in_uio_in_3 (
		.VGND (VGND),
		.VNB  (VGND),
		.VPB  (VPWR),
		.VPWR (VPWR),
		.A    (uio_in[3]),
		.X    ()
	);

	sky130_fd_sc_hd__clkbuf_2 buf_in_uio_in_4 (
		.VGND (VGND),
		.VNB  (VGND),
		.VPB  (VPWR),
		.VPWR (VPWR),
		.A    (uio_in[4]),
		.X    ()
	);

	sky130_fd_sc_hd__clkbuf_2 buf_in_uio_in_5 (
		.VGND (VGND),
		.VNB  (VGND),
		.VPB  (VPWR),
		.VPWR (VPWR),
		.A    (uio_in[5]),
		.X    ()
	);

	sky130_fd_sc_hd__clkbuf_2 buf_in_uio_in_6 (
		.VGND (VGND),
		.VNB  (VGND),
		.VPB  (VPWR),
		.VPWR (VPWR),
		.A    (uio_in[6]),
		.X    ()
	);

	sky130_fd_sc_hd__clkbuf_2 buf_in_uio_in_7 (
		.VGND (VGND),
		.VNB  (VGND),
		.VPB  (VPWR),
		.VPWR (VPWR),
		.A    (uio_in[7]),
		.X    ()
	);

	sky130_fd_sc_hd__clkbuf_2 buf_ctl_ena (
		.VGND (VGND),
		.VNB  (VGND),
		.VPB  (VPWR),
		.VPWR (VPWR),
		.A    (ena),
		.X    ()
	);

	sky130_fd_sc_hd__clkbuf_2 buf_in_clk (
		.VGND (VGND),
		.VNB  (VGND),
		.VPB  (VPWR),
		.VPWR (VPWR),
		.A    (clk),
		.X    ()
	);

	sky130_fd_sc_hd__clkbuf_2 buf_in_rst_n (
		.VGND (VGND),
		.VNB  (VGND),
		.VPB  (VPWR),
		.VPWR (VPWR),
		.A    (rst_n),
		.X    ()
	);

	sky130_fd_sc_hd__clkbuf_2 buf_out_uo_out_0 (
		.VGND (VGND),
		.VNB  (VGND),
		.VPB  (VPWR),
		.VPWR (VPWR),
		.A    (),
		.X    (uo_out[0])
	);

	sky130_fd_sc_hd__clkbuf_2 buf_out_uo_out_1 (
		.VGND (VGND),
		.VNB  (VGND),
		.VPB  (VPWR),
		.VPWR (VPWR),
		.A    (),
		.X    (uo_out[1])
	);

	sky130_fd_sc_hd__clkbuf_2 buf_out_uo_out_2 (
		.VGND (VGND),
		.VNB  (VGND),
		.VPB  (VPWR),
		.VPWR (VPWR),
		.A    (),
		.X    (uo_out[2])
	);

	sky130_fd_sc_hd__clkbuf_2 buf_out_uo_out_3 (
		.VGND (VGND),
		.VNB  (VGND),
		.VPB  (VPWR),
		.VPWR (VPWR),
		.A    (),
		.X    (uo_out[3])
	);

	sky130_fd_sc_hd__clkbuf_2 buf_out_uo_out_4 (
		.VGND (VGND),
		.VNB  (VGND),
		.VPB  (VPWR),
		.VPWR (VPWR),
		.A    (),
		.X    (uo_out[4])
	);

	sky130_fd_sc_hd__clkbuf_2 buf_out_uo_out_5 (
		.VGND (VGND),
		.VNB  (VGND),
		.VPB  (VPWR),
		.VPWR (VPWR),
		.A    (),
		.X    (uo_out[5])
	);

	sky130_fd_sc_hd__clkbuf_2 buf_out_uo_out_6 (
		.VGND (VGND),
		.VNB  (VGND),
		.VPB  (VPWR),
		.VPWR (VPWR),
		.A    (),
		.X    (uo_out[6])
	);

	sky130_fd_sc_hd__clkbuf_2 buf_out_uo_out_7 (
		.VGND (VGND),
		.VNB  (VGND),
		.VPB  (VPWR),
		.VPWR (VPWR),
		.A    (),
		.X    (uo_out[7])
	);

	sky130_fd_sc_hd__clkbuf_2 buf_out_uio_out_0 (
		.VGND (VGND),
		.VNB  (VGND),
		.VPB  (VPWR),
		.VPWR (VPWR),
		.A    (),
		.X    (uio_out[0])
	);

	sky130_fd_sc_hd__clkbuf_2 buf_out_uio_out_1 (
		.VGND (VGND),
		.VNB  (VGND),
		.VPB  (VPWR),
		.VPWR (VPWR),
		.A    (),
		.X    (uio_out[1])
	);

	sky130_fd_sc_hd__clkbuf_2 buf_out_uio_out_2 (
		.VGND (VGND),
		.VNB  (VGND),
		.VPB  (VPWR),
		.VPWR (VPWR),
		.A    (),
		.X    (uio_out[2])
	);

	sky130_fd_sc_hd__clkbuf_2 buf_out_uio_out_3 (
		.VGND (VGND),
		.VNB  (VGND),
		.VPB  (VPWR),
		.VPWR (VPWR),
		.A    (),
		.X    (uio_out[3])
	);

	sky130_fd_sc_hd__clkbuf_2 buf_out_uio_out_4 (
		.VGND (VGND),
		.VNB  (VGND),
		.VPB  (VPWR),
		.VPWR (VPWR),
		.A    (),
		.X    (uio_out[4])
	);

	sky130_fd_sc_hd__clkbuf_2 buf_out_uio_out_5 (
		.VGND (VGND),
		.VNB  (VGND),
		.VPB  (VPWR),
		.VPWR (VPWR),
		.A    (),
		.X    (uio_out[5])
	);

	sky130_fd_sc_hd__clkbuf_2 buf_out_uio_out_6 (
		.VGND (VGND),
		.VNB  (VGND),
		.VPB  (VPWR),
		.VPWR (VPWR),
		.A    (),
		.X    (uio_out[6])
	);

	sky130_fd_sc_hd__clkbuf_2 buf_out_uio_out_7 (
		.VGND (VGND),
		.VNB  (VGND),
		.VPB  (VPWR),
		.VPWR (VPWR),
		.A    (),
		.X    (uio_out[7])
	);

	sky130_fd_sc_hd__clkbuf_2 buf_out_uio_oe_0 (
		.VGND (VGND),
		.VNB  (VGND),
		.VPB  (VPWR),
		.VPWR (VPWR),
		.A    (),
		.X    (uio_oe[0])
	);

	sky130_fd_sc_hd__clkbuf_2 buf_out_uio_oe_1 (
		.VGND (VGND),
		.VNB  (VGND),
		.VPB  (VPWR),
		.VPWR (VPWR),
		.A    (),
		.X    (uio_oe[1])
	);

	sky130_fd_sc_hd__clkbuf_2 buf_out_uio_oe_2 (
		.VGND (VGND),
		.VNB  (VGND),
		.VPB  (VPWR),
		.VPWR (VPWR),
		.A    (),
		.X    (uio_oe[2])
	);

	sky130_fd_sc_hd__clkbuf_2 buf_out_uio_oe_3 (
		.VGND (VGND),
		.VNB  (VGND),
		.VPB  (VPWR),
		.VPWR (VPWR),
		.A    (),
		.X    (uio_oe[3])
	);

	sky130_fd_sc_hd__clkbuf_2 buf_out_uio_oe_4 (
		.VGND (VGND),
		.VNB  (VGND),
		.VPB  (VPWR),
		.VPWR (VPWR),
		.A    (),
		.X    (uio_oe[4])
	);

	sky130_fd_sc_hd__clkbuf_2 buf_out_uio_oe_5 (
		.VGND (VGND),
		.VNB  (VGND),
		.VPB  (VPWR),
		.VPWR (VPWR),
		.A    (),
		.X    (uio_oe[5])
	);

	sky130_fd_sc_hd__clkbuf_2 buf_out_uio_oe_6 (
		.VGND (VGND),
		.VNB  (VGND),
		.VPB  (VPWR),
		.VPWR (VPWR),
		.A    (),
		.X    (uio_oe[6])
	);

	sky130_fd_sc_hd__clkbuf_2 buf_out_uio_oe_7 (
		.VGND (VGND),
		.VNB  (VGND),
		.VPB  (VPWR),
		.VPWR (VPWR),
		.A    (),
		.X    (uio_oe[7])
	);

endmodule // {mod_name}
