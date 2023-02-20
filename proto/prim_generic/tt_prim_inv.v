/*
 * tt_prim_inv.v
 *
 * TT Primitive
 * Inverter
 *
 * Author: Sylvain Munaut <tnt@246tNt.com>
 */

`default_nettype none

module tt_prim_inv #(
	parameter integer HIGH_DRIVE = 0
)(
	input  wire a,
	output wire z
);

	assign z = ~a;

endmodule // tt_prim_inv
