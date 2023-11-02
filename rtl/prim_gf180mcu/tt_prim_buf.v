/*
 * tt_prim_buf.v
 *
 * TT Primitive
 * Buffer
 *
 * Author: Uri Shaked
 */

`default_nettype none

module tt_prim_buf #(
	parameter integer HIGH_DRIVE = 0
)(
	input  wire a,
	output wire z
);

	generate
		if (HIGH_DRIVE) begin
			gf180mcu_fd_sc_mcu7t5v0__buf_8 cell0_I (
`ifdef WITH_POWER
				.VDD (1'b1),
				.VSS (1'b0),
				.VPW (1'b1),
				.VNW (1'b0),
`endif
				.I (a),
				.Z (z)
			);
		end else begin
			gf180mcu_fd_sc_mcu7t5v0__buf_2 cell0_I (
`ifdef WITH_POWER
				.VDD (1'b1),
				.VSS (1'b0),
				.VPW (1'b1),
				.VNW (1'b0),
`endif
				.I (a),
				.Z (z)
			);
		end
	endgenerate

endmodule // tt_prim_buf
