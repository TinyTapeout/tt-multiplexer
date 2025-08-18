/*
 * tt_prim_tbuf_pol.v
 *
 * TT Primitive
 * Tristate buffer polarity handler
 *
 * Not all cells libraries have the same enable polarity ...
 * This converts positive enable polarity to whatever the
 * tt_prim_tbuf expects.
 *
 * Copyright (c) 2024 Sylvain Munaut <tnt@246tNt.com>
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_prim_tbuf_pol (
	input  wire t,
	output wire tx
);

	sg13g2_inv_8 cell0_I (
		.A (t),
		.Y (tx)
	);

endmodule // tt_prim_tbuf
