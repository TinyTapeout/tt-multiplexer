/*
 * tt_asw_3v3.v
 *
 * Blackbox for the analog switches
 *
 * Copyright (c) 2024 Sylvain Munaut <tnt@246tNt.com>
 * SPDX-License-Identifier: Apache-2.0
 */

(* blackbox *)
module tt_asw_3v3 (
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
