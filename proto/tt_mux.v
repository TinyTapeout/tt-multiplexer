/*
 * tt_mux.v
 *
 * Row mux for two rows of user modules (Top/Bottom)
 *
 * Author: Sylvain Munaut <tnt@246tNt.com>
 */

`default_nettype none

module tt_mux #(
	parameter integer N_UM = 8,
	parameter integer N_IO = 8,
	parameter integer N_O  = 8,
	parameter integer N_I  = 10,

	// auto-set
    parameter integer S_OW = N_O + N_IO * 2 + 2,
    parameter integer S_IW = N_I + N_IO + 10 + 1 + 2,

    parameter integer U_OW = N_O + N_IO * 2,
    parameter integer U_IW = N_I + N_IO
)(
	// Connections to user modules
	input  wire [(U_OW*N_UM)-1:0] um_ow,
	output wire [(U_IW*N_UM)-1:0] um_iw,
	output wire [      N_UM -1:0] um_ena,
	output wire [      N_UM -1:0] um_k_zero,

	// Vertical spine connection
	output wire [S_OW-1:0] spine_ow,
	input  wire [S_IW-1:0] spine_iw,

	// Config straps
	input  wire [4:0] addr,

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
	wire      [9:0] si_sel;
	wire            si_ena;
	wire            si_gl;

	// Horizontal distribution/collection bus
	wire            bus_gh;
	wire [U_OW-1:0] bus_ow;
	wire [U_IW-1:0] bus_iw;
	wire            bus_gm;
	wire      [4:0] bus_sel;
	wire            bus_ena;
	wire            bus_gl;

	// User Module connections as arrays
	wire [U_OW-1:0] um_owa[0:N_UM-1];
	wire [U_IW-1:0] um_iwa[0:N_UM-1];

	// Decoding
	wire            branch_sel;
	wire            branch_sel_tbe;


	// Spine mapping
	// -------------

	assign spine_ow = { so_gh, so_usr, so_gl };
	assign { si_gh, si_usr, si_sel, si_ena, si_gl } = spine_iw;

	assign so_gh = 1'b0;
	assign so_gl = 1'b0;

	// Diodes for inputs from spine
	tt_prim_diode diode_spine_I[S_IW-1:0] (
		.diode(spine_iw)
	);


	// Row decoding & Bus
	// ------------------

	// Decode branch address
	assign branch_sel = (si_sel[9:6] == addr[4:1]) & (si_sel[4] == addr[0]);

	tt_prim_tbuf_pol tbuf_row_ena_I (
		.t  (branch_sel),
		.tx (branch_sel_tbe)
	);

	// Spine drive TBUF for Outward
	tt_prim_tbuf tbuf_spine_ow_I[U_OW-1:0] (
		.a  (bus_ow),
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
		.a  ({si_sel[3:0], si_sel[5]}),
		.e  (branch_sel),
		.z  (bus_sel)
	);

	tt_prim_zbuf #(
		.HIGH_DRIVE(1)
	) zbuf_bus_ena_I (
		.a  (si_ena),
		.e  (branch_sel),
		.z  (bus_ena)
	);

	// Guards
	assign bus_gh  = 1'b0;
	assign bus_gm  = 1'b0;
	assign bus_gl  = 1'b0;


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

	wire [(N_UM/2)-1:0] col_sel_h;

	generate
		for (i=0; i<N_UM/2; i=i+1)
		begin : col
			// Signals
			wire [1:0] l_ena;

			// Mux-4
			if ((i & 1) == 0)
			begin
				// Signals
				wire [U_OW-1:0] l_ow;
				wire            l_tbe;

				// Decoder
				assign col_sel_h[i>>1] = bus_sel[4:2] == (i >> 1);

				// Mux
				tt_prim_mux4 mux4_I[U_OW-1:0] (
					.a(um_owa[i*2+0]),
					.b(um_owa[i*2+1]),
					.c(um_owa[i*2+2]),
					.d(um_owa[i*2+3]),
					.x(l_ow),
					.s(bus_sel[1:0])
				);

				// T-Buf
				tt_prim_tbuf_pol tbuf_row_ena_I (
					.t  (col_sel_h[i>>1]),
					.tx (l_tbe)
				);

				tt_prim_tbuf tbuf_spine_ow_I[U_OW-1:0] (
					.a  (l_ow),
					.tx (l_tbe),
					.z  (bus_ow)
				);
			end

			// Bottom
			assign l_ena[0] = bus_ena & col_sel_h[i>>1] & (bus_sel[1] == (i & 1)) & (bus_sel[0] == 1'b0);

			tt_prim_zbuf #(
				.HIGH_DRIVE(0)
			) zbuf_bot_iw_I[U_IW-1:0] (
				.a  (bus_iw),
				.e  (l_ena[0]),
				.z  (um_iwa[i*2+0])
			);

			tt_prim_zbuf #(
				.HIGH_DRIVE(0)
			) zbuf_bot_ena_I (
				.a  (1'b1),
				.e  (l_ena[0]),
				.z  (um_ena[i*2+0])
			);

			tt_prim_diode diode_bot_I[U_OW-1:0] (
				.diode (um_owa[i*2+0])
			);

			assign um_k_zero [i*2+0]  = 1'b0;

			// Top
			assign l_ena[1] = bus_ena & col_sel_h[i>>1] & (bus_sel[1] == (i & 1)) & (bus_sel[0] == 1'b1);

			tt_prim_zbuf #(
				.HIGH_DRIVE(0)
			) zbuf_top_iw_I[U_IW-1:0] (
				.a  (bus_iw),
				.e  (l_ena[1]),
				.z  (um_iwa[i*2+1])
			);

			tt_prim_zbuf #(
				.HIGH_DRIVE(0)
			) zbuf_top_ena_I (
				.a  (1'b1),
				.e  (l_ena[1]),
				.z  (um_ena[i*2+1])
			);

			tt_prim_diode diode_top_I[U_OW-1:0] (
				.diode (um_owa[i*2+1])
			);

			assign um_k_zero [i*2+1]  = 1'b0;

		end
	endgenerate


	// Tie points
	// ----------

	assign k_one  = 1'b1;
	assign k_zero = 1'b0;

endmodule // tt_mux
