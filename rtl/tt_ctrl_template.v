/*
 * tt_ctrl_template.v
 *
 * Controller module for TinyTapout mux
 * [Used for DEF Template generation]
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

	assign k_one  = 1'b1;
	assign k_zero = 1'b0;

endmodule // tt_ctrl
