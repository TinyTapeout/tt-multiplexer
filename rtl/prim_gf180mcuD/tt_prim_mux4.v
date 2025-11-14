/*
 * tt_prim_mux4.v
 *
 * TT Primitive
 * Mux4
 *
 * Copyright (c) 2025 Sylvain Munaut <tnt@246tNt.com>
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_prim_mux4 (
	input  wire a,
	input  wire b,
	input  wire c,
	input  wire d,
	output wire x,
	input  wire [1:0] s
);

`ifdef WITH_POWER
	wire VPWR = 1'b1;
	wire VGND = 1'b0;
`endif

	gf180mcu_fd_sc_mcu7t5v0__mux4_2 cell0_I (
`ifdef WITH_POWER
		.VDD (VPWR),
		.VSS (VGND),
		.VPW (VGND),
		.VNW (VPWR),
`endif
		.I0 (a),
		.I1 (b),
		.I2 (c),
		.I3 (d),
		.S0 (s[0]),
		.S1 (s[1]),
		.Z  (x)
	);

endmodule // tt_prim_mux4
