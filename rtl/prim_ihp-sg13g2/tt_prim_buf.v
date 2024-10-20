/*
 * tt_prim_buf.v
 *
 * TT Primitive
 * Buffer
 *
 * Copyright (c) 2024 Sylvain Munaut <tnt@246tNt.com>
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_prim_buf #(
	parameter integer HIGH_DRIVE = 0
)(
	input  wire a,
	output wire z
);

	generate
		if (HIGH_DRIVE) begin
			sg13g2_buf_8 cell0_I (
				.A (a),
				.X (z)
			);
		end else begin
			sg13g2_buf_2 cell0_I (
				.A (a),
				.X (z)
			);
		end
	endgenerate

endmodule // tt_prim_buf
