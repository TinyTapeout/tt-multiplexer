/*
 * tt_prim_mux2.v
 *
 * TT Primitive
 * Mux2
 *
 * Copyright (c) 2025 Sylvain Munaut <tnt@246tNt.com>
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_prim_mux2 (
	input  wire a,
	input  wire b,
	output wire x,
	input  wire s
);

`ifdef WITH_POWER
	wire VPWR = 1'b1;
	wire VGND = 1'b0;
`endif

	gf180mcu_fd_sc_mcu7t5v0__mux2_2 cell0_I (
`ifdef WITH_POWER
		.VDD (VPWR),
		.VSS (VGND),
		.VPW (VGND),
		.VNW (VPWR),
`endif
		.I0 (a),
		.I1 (b),
		.S  (s),
		.Z  (x)
	);

endmodule // tt_prim_mux2
