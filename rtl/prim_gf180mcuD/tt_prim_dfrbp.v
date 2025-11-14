/*
 * tt_prim_dfrbp.v
 *
 * TT Primitive
 * FF with positive edge clock, inverted reset, complementary outputs
 *
 * Copyright (c) 2025 Sylvain Munaut <tnt@246tNt.com>
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_prim_dfrbp (
	input  wire d,
	output wire q,
	output wire q_n,
	input  wire clk,
	input  wire rst_n
);

`ifdef WITH_POWER
	wire VPWR = 1'b1;
	wire VGND = 1'b0;
`endif

	gf180mcu_fd_sc_mcu7t5v0__dffrnq_2 cell0_I (
`ifdef WITH_POWER
		.VDD (VPWR),
		.VSS (VGND),
		.VPW (VGND),
		.VNW (VPWR),
`endif
		.D   (d),
		.Q   (q),
		.CLK (clk),
		.RN  (rst_n)
	);

	gf180mcu_fd_sc_mcu7t5v0__inv_2 cell1_I (
`ifdef WITH_POWER
		.VDD (VPWR),
		.VSS (VGND),
		.VPW (VGND),
		.VNW (VPWR),
`endif
		.I  (q),
		.ZN (q_n)
	);

endmodule // tt_prim_dfrbp
