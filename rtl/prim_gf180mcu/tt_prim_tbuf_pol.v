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
 * Author: Uri Shaked
 */

`default_nettype none

module tt_prim_tbuf_pol (
	input  wire t,
	output wire tx
);

	assign tx = t;

endmodule // tt_prim_tbuf
