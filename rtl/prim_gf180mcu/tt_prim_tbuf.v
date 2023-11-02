/*
 * tt_prim_tbuf.v
 *
 * TT Primitive
 * Tristate buffer, polarity variable ... see tt_prim_tbuf_pol
 *
 * Author: Uri Shaked
 */

`default_nettype none

module tt_prim_tbuf #(
	parameter integer HIGH_DRIVE = 0
) (
	input  wire a,
	input  wire tx,
	inout  wire z
);

	generate
		if (HIGH_DRIVE) begin
			gf180mcu_fd_sc_mcu7t5v0__bufz_8 cell0_I (
`ifdef WITH_POWER
				.VDD (1'b1),
				.VSS (1'b0),
				.VPW  (1'b1),
				.VNW  (1'b0),
`endif
				.I    (a),
				.EN   (tx),
				.Z    (z)
			);
		end else begin
			gf180mcu_fd_sc_mcu7t5v0__bufz_1 cell0_I (
`ifdef WITH_POWER
				.VDD (1'b1),
				.VSS (1'b0),
				.VPW  (1'b1),
				.VNW  (1'b0),
`endif
				.I    (a),
				.EN   (tx),
				.Z    (z)
			);
		end
	endgenerate

endmodule // tt_prim_tbuf
