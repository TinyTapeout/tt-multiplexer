/*
 * tt_prim_mux4.v
 *
 * TT Primitive
 * Mux4
 *
 * Copyright (c) 2024 Sylvain Munaut <tnt@246tNt.com>
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_prim_mux4 (
	input  wire a,
	input  wire b,
	input  wire c,
	input  wire d,
	output wire x,
	input  wire [1:0] s
);

	sg13g2_mux4_1 cell0_I (
		.A0 (a),
		.A1 (b),
		.A2 (c),
		.A3 (d),
		.S0 (s[0]),
		.S1 (s[1]),
		.X  (x)
	);

endmodule // tt_prim_mux4
