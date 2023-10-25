/*
 * tt_mux.v
 *
 * Row mux for two rows of user modules (Top/Bottom)
 *
 * Copyright (c) 2023 Sylvain Munaut <tnt@246tNt.com>
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none
`include "tt_defs.vh"

module tt_mux #(
	parameter integer N_UM = `TT_G_X,
	parameter integer N_IO = `TT_N_IO,
	parameter integer N_O  = `TT_N_O,
	parameter integer N_I  = `TT_N_I,

	// auto-set
	parameter integer S_OW = N_O + N_IO * 2 + 2,
	parameter integer S_IW = N_I + N_IO + 9 + 1 + 2,

	parameter integer U_OW = N_O + N_IO * 2,
	parameter integer U_IW = N_I + N_IO
)(
	// Connections to user modules
	input  wire [(U_OW*N_UM)-1:0] um_ow,
	output wire [(U_IW*N_UM)-1:0] um_iw,
	output wire [      N_UM -1:0] um_ena,
	output wire [      N_UM -1:0] um_k_zero,
	output wire [      N_UM -1:0] um_pg_vdd,

	// Vertical spine connection
	output wire [S_OW-1:0] spine_ow,
	input  wire [S_IW-1:0] spine_iw,

	// Config straps
	input  wire [3:0] addr,

	// Tie-offs
	output wire k_zero,
	output wire k_one
);

	// Signals
	// -------

	// Split spine connections
	wire            so_gh;
	wire [U_OW-1:0] so_usr;
	wire            so_gl;

	wire            si_gh;
	wire [U_IW-1:0] si_usr;
	wire      [8:0] si_sel;
	wire            si_ena;
	wire            si_gl;

	wire [U_OW-1:0] so_usr_pre;

	// Horizontal distribution/collection bus
	wire      [3:0] bus_gd;
	wire [U_OW-1:0] bus_ow;
	wire [U_IW-1:0] bus_iw;
	wire      [4:0] bus_sel;
	wire            bus_ena;

	// User Module connections as arrays
	wire [U_OW-1:0] um_owa[0:N_UM-1];
	wire [U_IW-1:0] um_iwa[0:N_UM-1];

	// Decoding
	wire            ena;
	wire      [3:0] addr_match;
	wire            branch_sel_weak;
	wire            branch_sel;
	wire            branch_sel_tbe;
	wire            branch_sel_n;
	wire            branch_sel_n_tbe;
	wire            tie_zero;


	// Spine mapping
	// -------------

	assign spine_ow = { so_gh, so_usr, so_gl };
	assign { si_gh, si_usr, si_sel, si_ena, si_gl } = spine_iw;

	// Guards
	tt_prim_tie #(
		.TIE_LO(1),
		.TIE_HI(0)
	) tie_spine_guard_I[1:0] (
		.lo({so_gh, so_gl})
	);

	// Diodes for inputs from spine
	tt_prim_diode diode_spine_I[S_IW-1:0] (
		.diode(spine_iw)
	);


	// Row decoding & Bus
	// ------------------

	// Decode branch address
	tt_prim_buf #(
		.HIGH_DRIVE(0)
	) branch_ena_buf_I (
		.a (si_ena),
		.z (ena)
	);

	tt_prim_buf #(
		.HIGH_DRIVE(0)
	) branch_addr_match_buf_I[3:0] (
		.a  (si_sel[8:5]),
		.z  (addr_match)
	);

	assign branch_sel_weak = ena & (addr == addr_match);

	tt_prim_buf #(
		.HIGH_DRIVE(1)
	) branch_sel_buf_I (
		.a  (branch_sel_weak),
		.z  (branch_sel)
	);

	tt_prim_inv #(
		.HIGH_DRIVE(0)
	) branch_sel_n_buf_I (
		.a  (branch_sel),
		.z  (branch_sel_n)
	);

	// Anti-float
	tt_prim_tbuf_pol tbuf_row_ena_n_I (
		.t  (branch_sel_n),
		.tx (branch_sel_n_tbe)
	);

	tt_prim_tie #(
		.TIE_LO(1),
		.TIE_HI(0)
	) bus_pull_tie_I (
		.lo(tie_zero)
	);

	tt_prim_tbuf #(
		.HIGH_DRIVE(0)
	) bus_pull_ow_I[U_OW-1:0] (
		.a  (tie_zero),
		.tx (branch_sel_n_tbe),
		.z  (bus_ow)
	);

	// Spine drive TBUF for Outward
	tt_prim_tbuf_pol tbuf_row_ena_I (
		.t  (branch_sel),
		.tx (branch_sel_tbe)
	);

	tt_prim_buf #(
		.HIGH_DRIVE(0)
	) buf_spine_ow_I[U_OW-1:0] (
		.a  (bus_ow),
		.z  (so_usr_pre)
	);

	tt_prim_tbuf #(
		.HIGH_DRIVE(1)
	) tbuf_spine_ow_I[U_OW-1:0] (
		.a  (so_usr_pre),
		.tx (branch_sel_tbe),
		.z  (so_usr)
	);

	// Zeroing buffer for Inward
	tt_prim_zbuf #(
		.HIGH_DRIVE(1)
	) zbuf_bus_iw_I[U_IW-1:0] (
		.a  (si_usr),
		.e  (branch_sel),
		.z  (bus_iw)
	);

	tt_prim_zbuf #(
		.HIGH_DRIVE(1)
	) zbuf_bus_sel_I[4:0] (
		.a  (si_sel[4:0]),
		.e  (branch_sel),
		.z  (bus_sel)
	);

	tt_prim_buf #(
		.HIGH_DRIVE(1)
	) buf_bus_ena_I (
		.a  (branch_sel),
		.z  (bus_ena)
	);

	// Guards
	tt_prim_tie #(
		.TIE_LO(1),
		.TIE_HI(0)
	) tie_bus_guard_I[3:0] (
		.lo(bus_gd)
	);


	// Columns
	// -------

	genvar i;
	generate
		for (i=0; i<N_UM; i=i+1)
		begin : map
			assign um_owa[i] = um_ow[U_OW*i+:U_OW];
			assign um_iw[U_IW*i+:U_IW] = um_iwa[i];
		end
	endgenerate

	wire [(N_UM/4)-1:0] grp_sel_h_weak;
	wire [(N_UM/4)-1:0] grp_sel_h;

	generate
		for (i=0; i<N_UM; i=i+1)
		begin : block
			// Signals
			wire l_ena_weak;
			wire l_ena;

			// Mux-4
			if ((i & 3) == 0)
			begin
				// Signals
				wire [U_OW-1:0] l_ow;
				wire            l_tbe;
				wire      [1:0] l_sel;

				// Decoder
				assign grp_sel_h_weak[i>>2] = bus_ena & (bus_sel[4:2] == (i >> 2));

				tt_prim_buf #(
					.HIGH_DRIVE(0)
				) grp_sel_buf_I (
					.a  (grp_sel_h_weak[i>>2]),
					.z  (grp_sel_h[i>>2])
				);

				// Mux
				tt_prim_buf #(
					.HIGH_DRIVE(0)
				) mux4_sel_buf_I[1:0] (
					.a  (bus_sel[1:0]),
					.z  (l_sel)
				);

				tt_prim_mux4 mux4_I[U_OW-1:0] (
					.a(um_owa[i+0]),
					.b(um_owa[i+1]),
					.c(um_owa[i+2]),
					.d(um_owa[i+3]),
					.x(l_ow),
					.s(l_sel)
				);

				// T-Buf
				tt_prim_tbuf_pol tbuf_blk_ena_I (
					.t  (grp_sel_h[i>>2]),
					.tx (l_tbe)
				);

				tt_prim_tbuf #(
					.HIGH_DRIVE(1)
				) tbuf_spine_ow_I[U_OW-1:0] (
					.a  (l_ow),
					.tx (l_tbe),
					.z  (bus_ow)
				);
			end

			// Block
			assign l_ena_weak = grp_sel_h[i>>2] & (bus_sel[1:0] == (i & 3));

			tt_prim_buf #(
				.HIGH_DRIVE(1)
			) l_ena_0_I (
				.a  (l_ena_weak),
				.z  (l_ena)
			);

			tt_prim_zbuf #(
				.HIGH_DRIVE(0)
			) zbuf_iw_I[U_IW-1:0] (
				.a  (bus_iw),
				.e  (l_ena),
				.z  (um_iwa[i])
			);

			tt_prim_zbuf #(
				.HIGH_DRIVE(0)
			) zbuf_ena_I (
				.a  (1'b1),
				.e  (l_ena),
				.z  (um_ena[i])
			);

			tt_prim_inv #(
				.HIGH_DRIVE(1)
			) zbuf_pg_vdd_I (
				.a  (l_ena),
				.z  (um_pg_vdd[i])
			);

			tt_prim_diode diode_I[U_OW-1:0] (
				.diode (um_owa[i])
			);

			tt_prim_tie #(
				.TIE_LO(1),
				.TIE_HI(0)
			) tie_I (
				.lo(um_k_zero[i])
			);

		end
	endgenerate


	// Tie points
	// ----------

	tt_prim_tie tie_I (
		.lo(k_zero),
		.hi(k_one)
	);

endmodule // tt_mux
