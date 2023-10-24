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
	parameter integer S_IW = N_I + N_IO + 9 + 1 + 2
)(
	// User pads connections
	input  wire  [N_IO-1:0] pad_uio_in,
	output wire  [N_IO-1:0] pad_uio_out,
	output wire  [N_IO-1:0] pad_uio_oe_n,

	output wire   [N_O-1:0] pad_uo_out,

	input  wire   [N_I-1:0] pad_ui_in,

	// Vertical spine connection
	input  wire  [S_OW-1:0] spine_top_ow,
	output wire  [S_IW-1:0] spine_top_iw,

	input  wire  [S_OW-1:0] spine_bot_ow,
	output wire  [S_IW-1:0] spine_bot_iw,

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
	wire            so_gh      [0:1];
	wire [N_IO-1:0] so_uio_oe  [0:1];
	wire [N_IO-1:0] so_uio_out [0:1];
	wire  [N_O-1:0] so_uo_out  [0:1];
	wire            so_gl      [0:1];

	wire            si_gh     [0:1];
	wire [N_IO-1:0] si_uio_in [0:1];
	wire  [N_I-1:0] si_ui_in  [0:1];
	wire      [8:0] si_sel    [0:1];
	wire            si_ena    [0:1];
	wire            si_gl     [0:1];

	// Control input buffer
	wire ctrl_sel_rst_n_ibuf;
	wire ctrl_sel_inc_ibuf;
	wire ctrl_ena_ibuf;

	// Selection
	wire [9:0] sel_cnt;
	wire [9:0] sel_cnt_n;
	wire [9:0] sel_cnt_clk;

	wire side_sel;
	wire side_ena [0:1];


	// Outward signals
	// ---------------

	// Signals
	wire  [N_IO-1:0] ibuf_uio_oe    [0:1];
	wire  [N_IO-1:0] ibuf_uio_out_n [0:1];
	wire   [N_O-1:0] ibuf_uo_out_n  [0:1];

	wire  [N_IO-1:0] mux_uio_oe;
	wire  [N_IO-1:0] mux_uio_out_n;
	wire   [N_O-1:0] mux_uo_out_n;

	// Mapping
	assign { so_gh[1], so_uio_oe[1], so_uio_out[1], so_uo_out[1], so_gl[1] } = spine_top_ow;
	assign { so_gh[0], so_uio_oe[0], so_uio_out[0], so_uo_out[0], so_gl[0] } = spine_bot_ow;

	// Protection diodes
	tt_prim_diode spine_diode_I[2*S_OW-1:0] (
		.diode ({spine_top_ow, spine_bot_ow})
	);

	// Input buffers
	tt_prim_buf #(
		.HIGH_DRIVE(0)
	) uio_oe_ibuf_I[2*N_IO-1:0] (
		.a ({   so_uio_oe[1],   so_uio_oe[0] }),
		.z ({ ibuf_uio_oe[1], ibuf_uio_oe[0] })
	);

	tt_prim_inv #(
		.HIGH_DRIVE(0)
	) uio_out_ibuf_I[2*N_IO-1:0] (
		.a ({     so_uio_out[1],     so_uio_out[0] }),
		.z ({ ibuf_uio_out_n[1], ibuf_uio_out_n[0] })
	);

	tt_prim_inv #(
		.HIGH_DRIVE(0)
	) uo_out_ibuf_I[2*N_O-1:0] (
		.a ({     so_uo_out[1],     so_uo_out[0] }),
		.z ({ ibuf_uo_out_n[1], ibuf_uo_out_n[0] })
	);

	// Muxing
	tt_prim_mux2 uio_oe_mux_I[N_IO-1:0](
		.a (ibuf_uio_oe[0]),
		.b (ibuf_uio_oe[1]),
		.x (mux_uio_oe),
		.s (side_sel)
	);

	tt_prim_mux2 uio_out_mux_I[N_IO-1:0](
		.a (ibuf_uio_out_n[0]),
		.b (ibuf_uio_out_n[1]),
		.x (mux_uio_out_n),
		.s (side_sel)
	);

	tt_prim_mux2 uo_out_mux_I[N_O-1:0](
		.a (ibuf_uo_out_n[0]),
		.b (ibuf_uo_out_n[1]),
		.x (mux_uo_out_n),
		.s (side_sel)
	);

	// Output buffers
	tt_prim_inv #(
		.HIGH_DRIVE(1)
	) uio_oe_obuf_I[N_IO-1:0] (
		.a (mux_uio_oe),
		.z (pad_uio_oe_n)
	);

	tt_prim_inv #(
		.HIGH_DRIVE(1)
	) uio_out_obuf_I[N_IO-1:0] (
		.a (mux_uio_out_n),
		.z (pad_uio_out)
	);

	tt_prim_inv #(
		.HIGH_DRIVE(1)
	) uo_out_obuf_I[N_O-1:0] (
		.a (mux_uo_out_n),
		.z (pad_uo_out)
	);

	// Floating net prevention
	generate
		for (i=0; i<2; i=i+1)
		begin

			wire tie_zero;
			wire pull;
			wire tx;

			tt_prim_tie #(
				.TIE_LO(1),
				.TIE_HI(0)
			) tie_I (
				.lo(tie_zero)
			);

			assign pull = ~ctrl_ena_ibuf | ~side_ena[i];

			tt_prim_tbuf_pol tbuf_pol_spine_ow_I (
				.t  (pull),
				.tx (tx)
			);

			tt_prim_tbuf #(
				.HIGH_DRIVE(0)
			) tbuf_spine_ow_I[S_OW-3:0] (
				.a  (tie_zero),
				.tx (tx),
				.z  ({so_uio_oe[i], so_uio_out[i], so_uo_out[i]})
			);

		end
	endgenerate


	// Inward signals
	// --------------

	// Pad diodes
	tt_prim_diode pad_uio_in_diode_I[N_IO-1:0] (
		.diode (pad_uio_in)
	);

	tt_prim_diode pad_ui_in_diode_I[N_I-1:0] (
		.diode (pad_ui_in)
	);

	// Spine split
	assign spine_top_iw = { si_gh[1], si_uio_in[1], si_ui_in[1], si_sel[1], si_ena[1], si_gl[1] };
	assign spine_bot_iw = { si_gh[0], si_uio_in[0], si_ui_in[0], si_sel[0], si_ena[0], si_gl[0] };

	// Generate for top/bottom spine
	// We already mask at this level to avoid unneeded toggling
	generate
		for (i=0; i<2; i=i+1)
		begin

			tt_prim_tie #(
				.TIE_LO(1),
				.TIE_HI(0)
			) tie_guard_I[1:0] (
				.lo({si_gh[i], si_gl[i]})
			);

			tt_prim_zbuf #(
				.HIGH_DRIVE(1)
			) pad_uio_in_buf_I[N_IO-1:0] (
				.a (pad_uio_in),
				.e (side_ena[i]),
				.z (si_uio_in[i])
			);

			tt_prim_zbuf #(
				.HIGH_DRIVE(1)
			) pad_ui_in_buf_I[N_I-1:0] (
				.a (pad_ui_in),
				.e (side_ena[i]),
				.z (si_ui_in[i])
			);

			tt_prim_zbuf #(
				.HIGH_DRIVE(1)
			) sel_cnt_buf_I[8:0] (
				.a ({sel_cnt[9:6], sel_cnt[4:0]}),
				.e (side_ena[i]),
				.z (si_sel[i])
			);

			tt_prim_zbuf #(
				.HIGH_DRIVE(1)
			) ctrl_ena_buf_I (
				.a (ctrl_ena_ibuf),
				.e (side_ena[i]),
				.z (si_ena[i])
			);

		end
	endgenerate


	// Selection
	// ---------

	tt_prim_diode ctrl_diode_I[2:0] (
		.diode ({ ctrl_sel_rst_n, ctrl_sel_inc, ctrl_ena })
	);

	tt_prim_buf #(
		.HIGH_DRIVE(0)
	) ctrl_ibuf_I[2:0] (
		.a ({ ctrl_sel_rst_n,      ctrl_sel_inc,      ctrl_ena }),
		.z ({ ctrl_sel_rst_n_ibuf, ctrl_sel_inc_ibuf, ctrl_ena_ibuf })
	);


	genvar i;
	generate
		for (i=0; i<10; i=i+1)
		begin : sel_cnt_gen
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

	tt_prim_buf #(
		.HIGH_DRIVE(1)
	) side_sel_buf_I (
		.a (sel_cnt[5]),
		.z (side_sel)
	);

	tt_prim_inv #(
		.HIGH_DRIVE(1)
	) side_ena0_buf_I (
		.a (sel_cnt[5]),
		.z (side_ena[0])
	);

	tt_prim_buf #(
		.HIGH_DRIVE(1)
	) side_ena1_buf_I (
		.a (sel_cnt[5]),
		.z (side_ena[1])
	);


	// Tie points
	// ----------

	tt_prim_tie tie_I (
		.lo(k_zero),
		.hi(k_one)
	);

endmodule // tt_ctrl
