/*
 * tt_asw_5v0.v
 *
 * Blackbox for the analog switches
 *
 * Copyright (c) 2024 Sylvain Munaut <tnt@246tNt.com>
 * SPDX-License-Identifier: Apache-2.0
 */

(* blackbox *)
module tt_asw_5v0 (
`ifdef USE_POWER_PINS
	input  wire VGND,
	input  wire VDPWR,
	input  wire VAPWR,
`endif
	inout  wire mod,
	inout  wire bus,
	input  wire ctrl
);

endmodule
