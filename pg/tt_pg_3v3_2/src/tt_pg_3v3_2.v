/*
 * tt_pg_3v3_2.v
 *
 * Blackbox for the 3v3 power gate
 *
 * Copyright (c) 2024 Sylvain Munaut <tnt@246tNt.com>
 * SPDX-License-Identifier: Apache-2.0
 */

(* blackbox *)
module tt_pg_3v3_2 (
`ifdef USE_POWER_PINS
	input  wire VGND,
	input  wire VPWR,
	output wire GPWR,
`endif
	input  wire ctrl
);

`ifdef USE_POWER_PINS
	assign GPWR = ctrl ? VPWR : 1'bz;
`endif

endmodule
