/*
 * tt_prim_mux2.v
 *
 * TT Primitive
 * Mux2
 *
 * Copyright (c) 2024 Sylvain Munaut <tnt@246tNt.com>
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_prim_mux2 (
	input  wire a,
	input  wire b,
	output wire x,
	input  wire s
);

	sg13g2_mux2_1 cell0_I (
		.A0 (a),
		.A1 (b),
		.S  (s),
		.X  (x)
	);

endmodule // tt_prim_mux2
