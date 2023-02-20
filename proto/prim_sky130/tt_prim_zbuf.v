/*
 * tt_prim_zbuf.v
 *
 * TT Primitive
 * Zeroing buffer (i.e. AND gate ...)
 *
 * Author: Sylvain Munaut <tnt@246tNt.com>
 */

`default_nettype none

module tt_prim_zbuf #(
	parameter integer HIGH_DRIVE = 0
)(
	input  wire a,
	input  wire e,
	output wire z
);

	generate
		if (HIGH_DRIVE) begin
			wire l;

			sky130_fd_sc_hd__and2_1 cell0_I (
`ifdef WITH_POWER
				.VPWR (1'b1),
				.VGND (1'b0),
`endif
				.A (a),
				.B (e),
				.X (l)
			);

			sky130_fd_sc_hd__buf_8 cell1_I (
`ifdef WITH_POWER
				.VPWR (1'b1),
				.VGND (1'b0),
`endif
				.A (l),
				.X (z)
			);
			
		end else begin
			sky130_fd_sc_hd__and2_2 cell0_I (
`ifdef WITH_POWER
				.VPWR (1'b1),
				.VGND (1'b0),
`endif
				.A (a),
				.B (e),
				.X (z)
			);
		end
	endgenerate

endmodule // tt_prim_zbuf
