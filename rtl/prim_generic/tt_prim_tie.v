/*
 * tt_prim_tie.v
 *
 * TT Primitive
 * Tie Lo/Hi
 *
 * Copyright (c) 2023 Sylvain Munaut <tnt@246tNt.com>
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

	assign lo = TIE_LO ? 1'b0 : 1'bz;
	assign hi = TIE_HI ? 1'b1 : 1'bz;

endmodule // tt_prim_tie
