/*
 * tt_prim_tie.v
 *
 * TT Primitive
 * Tie Lo/Hi
 *
 * Copyright (c) 2024 Sylvain Munaut <tnt@246tNt.com>
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_prim_tie #(
	parameter integer TIE_LO = 1,
	parameter integer TIE_HI = 1
)(
	output wire lo,
	output wire hi
);

	generate

		if (TIE_LO)
			sg13g2_tielo cell0_I ( .L_LO(lo) );

		if (TIE_HI)
			sg13g2_tiehi cell1_I ( .L_HI(hi) );

	endgenerate

endmodule // tt_prim_tie
