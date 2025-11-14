/*
 * tt_prim_tbuf.v
 *
 * TT Primitive
 * Tristate buffer, polarity variable ... see tt_prim_tbuf_pol
 *
 * Copyright (c) 2025 Sylvain Munaut <tnt@246tNt.com>
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_prim_tbuf #(
	parameter integer HIGH_DRIVE = 0
)(
	input  wire a,
	input  wire tx,
	output wire z
);

`ifdef WITH_POWER
	wire VPWR = 1'b1;
	wire VGND = 1'b0;
`endif

	generate
		if (HIGH_DRIVE) begin
			gf180mcu_fd_sc_mcu7t5v0__bufz_12 cell0_I (
`ifdef WITH_POWER
				.VDD (VPWR),
				.VSS (VGND),
				.VPW (VGND),
				.VNW (VPWR),
`endif
				.I  (a),
				.EN (tx),
				.Z  (z)
			);
		end else begin
			gf180mcu_fd_sc_mcu7t5v0__bufz_1 cell0_I (
`ifdef WITH_POWER
				.VDD (VPWR),
				.VSS (VGND),
				.VPW (VGND),
				.VNW (VPWR),
`endif
				.I  (a),
				.EN (tx),
				.Z  (z)
			);
		end
	endgenerate

endmodule // tt_prim_tbuf
