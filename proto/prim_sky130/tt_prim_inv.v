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

	generate
		if (HIGH_DRIVE) begin
			sky130_fd_sc_hd__inv_8 cell0_I (
`ifdef WITH_POWER
				.VPWR (1'b1),
				.VGND (1'b0),
`endif
				.A (a),
				.Y (z)
			);
		end else begin
			sky130_fd_sc_hd__inv_2 cell0_I (
`ifdef WITH_POWER
				.VPWR (1'b1),
				.VGND (1'b0),
`endif
				.A (a),
				.Y (z)
			);
		end
	endgenerate

endmodule // tt_prim_inv
