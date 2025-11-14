/*
 * tt_prim_zbuf.v
 *
 * TT Primitive
 * Zeroing buffer (i.e. AND gate ...)
 *
 * Copyright (c) 2025 Sylvain Munaut <tnt@246tNt.com>
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_prim_zbuf #(
	parameter integer HIGH_DRIVE = 0
)(
	input  wire a,
	input  wire e,
	output wire z
);

`ifdef WITH_POWER
	wire VPWR = 1'b1;
	wire VGND = 1'b0;
`endif

	generate
		if (HIGH_DRIVE) begin
			wire l;

			gf180mcu_fd_sc_mcu7t5v0__and2_2 cell0_I (
`ifdef WITH_POWER
				.VDD (VPWR),
				.VSS (VGND),
				.VPW (VGND),
				.VNW (VPWR),
`endif
				.A1 (a),
				.A2 (e),
				.Z  (l)
			);

			gf180mcu_fd_sc_mcu7t5v0__buf_8 cell1_I (
`ifdef WITH_POWER
				.VDD (VPWR),
				.VSS (VGND),
				.VPW (VGND),
				.VNW (VPWR),
`endif
				.I (l),
				.Z (z)
			);
			
		end else begin
			gf180mcu_fd_sc_mcu7t5v0__and2_2 cell0_I (
`ifdef WITH_POWER
				.VDD (VPWR),
				.VSS (VGND),
				.VPW (VGND),
				.VNW (VPWR),
`endif
				.A1 (a),
				.A2 (e),
				.Z  (z)
			);
		end
	endgenerate

endmodule // tt_prim_zbuf
