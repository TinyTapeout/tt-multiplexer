/*
 * tt_prim_mux4.v
 *
 * TT Primitive
 * Mux4
 *
 * Author: Sylvain Munaut <tnt@246tNt.com>
 */

`default_nettype none

module tt_prim_mux4 (
	input  wire a,
	input  wire b,
	input  wire c,
	input  wire d,
	output wire x,
	input  wire [1:0] s
);

	sky130_fd_sc_hd__mux4_1 cell0_I (
`ifdef WITH_POWER
		.VPWR (1'b1),
		.VGND (1'b0),
`endif
		.A0 (a),
		.A1 (b),
		.A2 (c),
		.A3 (d),
		.S0 (s[0]),
		.S1 (s[1]),
		.X  (x)
	);

endmodule // tt_prim_mux4
