/*
 * tt_pg_1v8_ll_1.v
 *
 * Blackbox for the 1v8 power gate (low-leakage variant)
 *
 * Copyright (c) 2024 Sylvain Munaut <tnt@246tNt.com>
 * SPDX-License-Identifier: Apache-2.0
 */

(* blackbox *)
module tt_pg_1v8_ll_1 (
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
