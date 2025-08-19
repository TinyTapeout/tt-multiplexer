/*
 * tt_pg_1v5_ll_4.v
 *
 * Blackbox for the 1v5 power gate
 *
 * Copyright (c) 2025 Sylvain Munaut <tnt@246tNt.com>
 * SPDX-License-Identifier: Apache-2.0
 */

(* blackbox *)
module tt_pg_1v5_ll_4 (
`ifdef USE_POWER_PINS
	input  wire VGND,
	input  wire VPWR,
	output wire GPWR,
`endif
	input  wire ctrl
);

`ifdef USE_POWER_PINS
	assign GPWR = ctrl ? VPWR : VGND;
`endif

endmodule
