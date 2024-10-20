/*
 * tt_prim_inv.v
 *
 * TT Primitive
 * Inverter
 *
 * Copyright (c) 2024 Sylvain Munaut <tnt@246tNt.com>
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_prim_inv #(
	parameter integer HIGH_DRIVE = 0
)(
	input  wire a,
	output wire z
);

	generate
		if (HIGH_DRIVE) begin
			sg13g2_inv_8 cell0_I (
				.A (a),
				.Y (z)
			);
		end else begin
			sg13g2_inv_2 cell0_I (
				.A (a),
				.Y (z)
			);
		end
	endgenerate

endmodule // tt_prim_inv
