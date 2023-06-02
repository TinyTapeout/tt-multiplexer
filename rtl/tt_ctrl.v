/*
 * tt_ctrl.v
 *
 * Controller module for TinyTapout mux
 *
 * Copyright (c) 2023 Sylvain Munaut <tnt@246tNt.com>
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none
`include "tt_defs.vh"

module tt_ctrl #(
	parameter integer N_IO = `TT_N_IO,
	parameter integer N_O  = `TT_N_O,
	parameter integer N_I  = `TT_N_I,

	// auto-set
	parameter integer S_OW = N_O + N_IO * 2 + 2,
	parameter integer S_IW = N_I + N_IO + 10 + 1 + 2
)(
	// User pads connections
	input  wire  [N_IO-1:0] pad_uio_in,
	output wire  [N_IO-1:0] pad_uio_out,
	output wire  [N_IO-1:0] pad_uio_oe_n,

	output wire   [N_O-1:0] pad_uo_out,

	input  wire   [N_I-1:0] pad_ui_in,

	// Vertical spine connection
	input  wire  [S_OW-1:0] spine_ow,
	output wire  [S_IW-1:0] spine_iw,

	// Control interface
	input  wire ctrl_sel_rst_n,
	input  wire ctrl_sel_inc,
	input  wire ctrl_ena,

	// Convenient constants for top-level tie-offs
	output wire k_one,
	output wire k_zero
);

	// Signals
	// -------

	// Split spine connections
	wire            so_gh;
	wire [N_IO-1:0] so_uio_oe;
	wire [N_IO-1:0] so_uio_out;
	wire  [N_O-1:0] so_uo_out;
	wire            so_gl;

	wire            si_gh;
	wire [N_IO-1:0] si_uio_in;
	wire  [N_I-1:0] si_ui_in;
	wire      [9:0] si_sel;
	wire            si_ena;
	wire            si_gl;

	// Selection
	wire [9:0] sel_cnt;
	wire [9:0] sel_cnt_n;
	wire [9:0] sel_cnt_clk;


	// Spine mapping
	// -------------

	assign { so_gh, so_uio_oe, so_uio_out, so_uo_out, so_gl } = spine_ow;

	tt_prim_diode spine_diode_I[S_OW-1:0] (
		.diode (spine_ow)
	);

	tt_prim_inv #(
		.HIGH_DRIVE(1)
	) pad_uio_oe_n_buf_I[N_IO-1:0] (
		.a (so_uio_oe),
		.z (pad_uio_oe_n)
	);

	tt_prim_buf #(
		.HIGH_DRIVE(1)
	) pad_uio_out_buf_I[N_IO-1:0] (
		.a (so_uio_out),
		.z (pad_uio_out)
	);

	tt_prim_buf #(
		.HIGH_DRIVE(1)
	) pad_uo_out_buf_I[N_O-1:0] (
		.a (so_uo_out),
		.z (pad_uo_out)
	);

	assign spine_iw = { si_gh, si_uio_in, si_ui_in, si_sel, si_ena, si_gl };

	tt_prim_tie #(
		.TIE_LO(1),
		.TIE_HI(0)
	) tie_guard_I[1:0] (
		.lo({si_gh, si_gl})
	);

	tt_prim_diode pad_uio_in_diode_I[N_IO-1:0] (
		.diode (pad_uio_in)
	);

	tt_prim_diode pad_ui_in_diode_I[N_I-1:0] (
		.diode (pad_ui_in)
	);

	tt_prim_buf #(
		.HIGH_DRIVE(1)
	) pad_uio_in_buf_I[N_IO-1:0] (
		.a (pad_uio_in),
		.z (si_uio_in)
	);

	tt_prim_buf #(
		.HIGH_DRIVE(1)
	) pad_ui_in_buf_I[N_I-1:0] (
		.a (pad_ui_in),
		.z (si_ui_in)
	);

	tt_prim_buf #(
		.HIGH_DRIVE(1)
	) sel_cnt_buf_I[9:0] (
		.a (sel_cnt),
		.z (si_sel)
	);

	tt_prim_buf #(
		.HIGH_DRIVE(1)
	) ctrl_ena_buf_I (
		.a (ctrl_ena),
		.z (si_ena)
	);


	// Selection
	// ---------

	wire ctrl_sel_rst_n_ibuf;
	wire ctrl_sel_inc_ibuf;

	tt_prim_diode ctrl_diode_I[2:0] (
		.diode ({ ctrl_sel_rst_n, ctrl_sel_inc, ctrl_ena })
	);

	tt_prim_buf #(
		.HIGH_DRIVE(0)
	) ctrl_ibuf_I[1:0] (
		.a ({ ctrl_sel_inc,      ctrl_sel_rst_n      }),
		.z ({ ctrl_sel_inc_ibuf, ctrl_sel_rst_n_ibuf })
	);


	genvar i;
	generate
		for (i=0; i<10; i=i+1) begin
			tt_prim_dfrbp cnt_bit_I (
				.d     (sel_cnt_n[i]),
				.q     (sel_cnt[i]),
				.q_n   (sel_cnt_n[i]),
				.clk   (sel_cnt_clk[i]),
				.rst_n (ctrl_sel_rst_n_ibuf)
			);
		end
	endgenerate

	assign sel_cnt_clk = { sel_cnt_n[8:0], ctrl_sel_inc_ibuf };


	// Tie points
	// ----------

	tt_prim_tie tie_I (
		.lo(k_zero),
		.hi(k_one)
	);

endmodule // tt_ctrl
