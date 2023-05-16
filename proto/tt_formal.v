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

    // loop back outs to ins
    assign io_in[15:8] = io_out[23:16];


endmodule // tt_formal

