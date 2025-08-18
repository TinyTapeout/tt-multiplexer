/*
 * tt_prim_zbuf.v
 *
 * TT Primitive
 * Zeroing buffer (i.e. AND gate ...)
 *
 * Copyright (c) 2024 Sylvain Munaut <tnt@246tNt.com>
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_prim_zbuf #(
	parameter integer HIGH_DRIVE = 0
)(
	input  wire a,
	input  wire e,
	output wire z
);

	generate
		if (HIGH_DRIVE) begin
			wire l;

			sg13g2_and2_2 cell0_I (
				.A (a),
				.B (e),
				.X (l)
			);

			sg13g2_buf_8 cell1_I (
				.A (l),
				.X (z)
			);

		end else begin
			sg13g2_and2_2 cell0_I (
				.A (a),
				.B (e),
				.X (z)
			);
		end
	endgenerate

endmodule // tt_prim_zbuf
