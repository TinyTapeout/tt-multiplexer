/*
 * tt_prim_tbuf.v
 *
 * TT Primitive
 * Tristate buffer, polarity variable ... see tt_prim_tbuf_pol
 *
 * Author: Sylvain Munaut <tnt@246tNt.com>
 */

`default_nettype none

module tt_prim_tbuf (
	input  wire a,
	input  wire tx,
	output wire z
);

	assign z = tx ? a : 1'bz;

endmodule // tt_prim_tbuf
