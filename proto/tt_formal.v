/*
 * tt_formal.v
 *
 * Formal connectivity check
 *
 * Author: Matt Venn <matt@mattvenn.net>
 */

`default_nettype none
`timescale 1ns / 100ps

module tt_formal;

	// Signals
	// -------

	// DUT signals
	wire [37:0] io_in;
	wire [37:0] io_out;
	wire [37:0] io_oeb;
	wire        user_clock2;
	wire        k_zero;
	wire        k_one;

	// Control
	wire        ctrl_sel_rst_n;
	reg         ctrl_sel_inc;
	reg         ctrl_ena;

	reg [3:0]   um_rst_cnt;


	// Clocks
	reg  clk_a = 1'b0;
	reg  clk_b = 1'b0;
	reg  rst_n = 1'b0;


	// DUT
	// ---

	tt_top #(
		.N_PADS (38),
		.G_X    (16),
		.G_Y    (24),
		.N_IO   (8),
		.N_O    (8),
		.N_I    (10)
	) dut_I (
		.io_in       (io_in),
		.io_out      (io_out),
		.io_oeb      (io_oeb),
		.user_clock2 (user_clock2),
		.k_zero      (k_zero),
		.k_one       (k_one)
	);

	// DUT connections
	// ---------------

	assign user_clock2 = clk_b;

	assign io_in[36] = ctrl_sel_rst_n;
	assign io_in[34] = ctrl_sel_inc;
	assign io_in[32] = ctrl_ena;

	assign io_in[6] = io_out[5];	// Loop back clk_out to clk_in
	assign io_in[7] = um_rst_cnt[3];
	assign io_in[8] = 1'b1;


	always @(negedge io_out[5])
			if (~ctrl_ena)
				um_rst_cnt <= 0;
			else if (~um_rst_cnt[3])
				um_rst_cnt <= um_rst_cnt + 1;


	// Core Selection
	// --------------
    // do nothing, allow solver to pick

	assign ctrl_sel_rst_n = rst_n;


endmodule // tt_formal

