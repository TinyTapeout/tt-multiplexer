/*
 * tt_prim_tbuf_pol.v
 *
 * TT Primitive
 * Tristate buffer polarity handler
 *
 * Not all cells libraries have the same enable polarity ...
 * This converts positive enable polarity to whatever the
 * tt_prim_tbuf expects.
 *
 * Copyright (c) 2025 Sylvain Munaut <tnt@246tNt.com>
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_prim_tbuf_pol (
	input  wire t,
	output wire tx
);

`ifdef WITH_POWER
	wire VPWR = 1'b1;
	wire VGND = 1'b0;
`endif

	gf180mcu_fd_sc_mcu7t5v0__buf_8 cell0_I (
`ifdef WITH_POWER
		.VDD (VPWR),
		.VSS (VGND),
		.VPW (VGND),
		.VNW (VPWR),
`endif
		.I (t),
		.Z (tx)
	);

endmodule // tt_prim_tbuf
