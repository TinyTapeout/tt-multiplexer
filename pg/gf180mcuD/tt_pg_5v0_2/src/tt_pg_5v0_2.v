/*
 * tt_pg_5v0_1.v
 *
 * Blackbox for the 5v0 power gate
 *
 * Copyright (c) 2026 Sylvain Munaut <tnt@246tNt.com>
 * SPDX-License-Identifier: Apache-2.0
 */

(* blackbox *)
module tt_pg_5v0_2 (
`ifdef USE_POWER_PINS
	input  wire VGND,
	input  wire VDPWR,
	input  wire VAPWR,
	output wire GAPWR,
`endif
	input  wire ctrl
);

`ifdef USE_POWER_PINS
	assign GAPWR = ctrl ? VAPWR : 1'bz;
`endif

endmodule
