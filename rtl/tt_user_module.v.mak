/*
 * tt_user_module.v
 *
 * Wrapper to instanciate correct user module according to
 * grid position.
 *
 * Also maps signals to more "human" names
 *
 * Copyright (c) 2023 Sylvain Munaut <tnt@246tNt.com>
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_user_module #(
	// Logical  Position
	parameter integer MUX_ID = 0,
	parameter integer BLK_ID = 0,

	// Config
	parameter integer N_A    = 8,
	parameter integer N_IO   = 8,
	parameter integer N_O    = 8,
	parameter integer N_I    = 10,

	// auto-set
	parameter integer N_OW = N_O + N_IO * 2 ,
	parameter integer N_IW = N_I + N_IO
)(
	inout  wire   [N_A-1:0] ana,
	output wire  [N_OW-1:0] ow,
	input  wire  [N_IW-1:0] iw,
	input  wire             ena,
	input  wire             k_zero,
	input  wire             pg_vdd
);

	wire [7:0] uio_in;
	wire [7:0] uio_out;
	wire [7:0] uio_oe;
	wire [7:0] uo_out;
	wire [7:0] ui_in;
	wire       clk;
	wire       rst_n;

	assign { uio_in, ui_in, rst_n, clk } = iw;
	assign ow = { uio_oe, uio_out, uo_out };

	generate
% for (mux_id, blk_id), mod in grid.items():
		if ((MUX_ID == ${mux_id}) && (BLK_ID == ${blk_id}))
		begin : block_${mux_id}_${blk_id}
			tt_um_${mod.name} tt_um_I (
% if mod.analog:
				.ua      (ana),
% endif
				.uio_in  (uio_in),
				.uio_out (uio_out),
				.uio_oe  (uio_oe),
				.uo_out  (uo_out),
				.ui_in   (ui_in),
				.ena     (ena),
				.clk     (clk),
				.rst_n   (rst_n)
			);
% if mod.pg_vdd:
			tt_pg_vdd_${mod.height} tt_pg_vdd_I (
				.ctrl    (pg_vdd)
			);
% endif
		end
% endfor

% for (mux_id, blk_id) in grid.keys():
		if ((MUX_ID == ${mux_id}) && (BLK_ID == ${blk_id}))
		begin
		end
		else
% endfor
		begin
			// Tie-off
			assign ow = { N_OW{k_zero} };
		end
	endgenerate

endmodule // tt_user_module
