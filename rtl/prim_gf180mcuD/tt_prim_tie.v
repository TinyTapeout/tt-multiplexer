/*
 * tt_prim_tie.v
 *
 * TT Primitive
 * Tie Lo/Hi
 *
 * Copyright (c) 2025 Sylvain Munaut <tnt@246tNt.com>
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_prim_tie #(
	parameter integer TIE_LO = 1,
	parameter integer TIE_HI = 1
)(
	output wire lo,
	output wire hi
);

`ifdef WITH_POWER
	wire VPWR = 1'b1;
	wire VGND = 1'b0;
`endif

	generate

		if (TIE_LO)
			gf180mcu_fd_sc_mcu7t5v0__tiel cell_lo_I (
`ifdef WITH_POWER
				.VDD (VPWR),
				.VSS (VGND),
				.VPW (VGND),
				.VNW (VPWR),
`endif
				.ZN (lo)
			);

		if (TIE_HI)
			gf180mcu_fd_sc_mcu7t5v0__tieh cell_hi_I (
`ifdef WITH_POWER
				.VDD (VPWR),
				.VSS (VGND),
				.VPW (VGND),
				.VNW (VPWR),
`endif
				.Z (hi)
			);

	endgenerate

endmodule // tt_prim_tie
