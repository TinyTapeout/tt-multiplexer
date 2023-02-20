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

	sky130_fd_sc_hd__ebufn_8 cell0_I (
`ifdef WITH_POWER
		.VPWR (1'b1),
		.VGND (1'b0),
		.VPB  (1'b1),
		.VNB  (1'b0),
`endif
		.A    (a),
		.TE_B (tx),
		.Z    (z)
	);

endmodule // tt_prim_tbuf
