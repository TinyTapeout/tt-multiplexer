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
	parameter integer N_AE   = 12,
	parameter integer N_AU   = 8,
	parameter integer N_IO   = 8,
	parameter integer N_O    = 8,
	parameter integer N_I    = 10,

	// auto-set
	parameter integer N_OW = N_O + N_IO * 2 ,
	parameter integer N_IW = N_I + N_IO
)(
`ifdef USE_POWER_PINS
	input  wire VDPWR,
	input  wire VAPWR,
	input  wire VGND,
`endif
	inout  wire  [N_AE-1:0] ana,
	output wire  [N_OW-1:0] ow,
	input  wire  [N_IW-1:0] iw,
	input  wire             ena,
	input  wire             k_zero,
	input  wire             pg_ena
);

	wire [N_AU-1:0] ua;
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
`ifdef USE_POWER_PINS
			wire l_vdpwr;
`endif
			tt_um_${mod.name} tt_um_I (
`ifdef USE_POWER_PINS
				.VDPWR   (l_vdpwr),
				.VGND    (VGND),
`endif
%  if mod.analog:
				.ua      (ua),
%  endif
				.uio_in  (uio_in),
				.uio_out (uio_out),
				.uio_oe  (uio_oe),
				.uo_out  (uo_out),
				.ui_in   (ui_in),
				.ena     (ena),
				.clk     (clk),
				.rst_n   (rst_n)
			);
%  if mod.analog:
%   for (pin_int, pin_ext) in mod.analog.items():
			tt_asw_3v3 tt_asw_${pin_int}_I (
`ifdef USE_POWER_PINS
				.VDPWR   (VDPWR),
				.VAPWR   (VAPWR),
				.VGND    (VGND),
`endif
				.mod     (ua[${pin_int}]),
				.bus     (ana[${pin_ext}]),
				.ctrl	 (ena)
			);
%   endfor
%  endif
%  if mod.pg_vdd:
			tt_pg_1v8_${mod.height} tt_pg_vdd_I (
`ifdef USE_POWER_PINS
				.GPWR    (l_vdpwr),
				.VPWR    (VDPWR),
				.VGND    (VGND),
`endif
				.ctrl    (pg_ena)
			);
%  else:
`ifdef USE_POWER_PINS
			assign l_vdpwr = VDPWR;
`endif
%  endif
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
