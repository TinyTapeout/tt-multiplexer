/*
 * tt_prim_tbuf.v
 *
 * TT Primitive
 * Tristate buffer, polarity variable ... see tt_prim_tbuf_pol
 *
 * Copyright (c) 2024 Sylvain Munaut <tnt@246tNt.com>
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_prim_tbuf #(
	parameter integer HIGH_DRIVE = 0
)(
	input  wire a,
	input  wire tx,
	output wire z
);

	generate
		if (HIGH_DRIVE) begin
			sg13g2_ebufn_8 cell0_I (
				.A    (a),
				.TE_B (tx),
				.Z    (z)
			);
		end else begin
			sg13g2_ebufn_2 cell0_I (
				.A    (a),
				.TE_B (tx),
				.Z    (z)
			);
		end
	endgenerate

endmodule // tt_prim_tbuf
