/*
 * tt_prim_dfrbp.v
 *
 * TT Primitive
 * FF with positive edge clock, inverted reset, complementary outputs
 *
 * Author: Sylvain Munaut <tnt@246tNt.com>
 */

`default_nettype none

module tt_prim_dfrbp (
	input  wire d,
	output wire q,
	output wire q_n,
	input  wire clk,
	input  wire rst_n
);

	sky130_fd_sc_hd__dfrbp_1 cell0_I (
`ifdef WITH_POWER
		.VPWR (1'b1),
		.VGND (1'b0),
`endif
		.D       (d),
		.Q       (q),
		.Q_N     (q_n),
		.CLK     (clk),
		.RESET_B (rst_n)
	);

endmodule // tt_prim_dfrbp
