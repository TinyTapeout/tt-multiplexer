/*
 * tt_formal.v
 *
 * Formal connectivity check
 *
 * Copyright (c) 2023 Matt Venn <matt@mattvenn.net>
 * SPDX-License-Identifier: Apache-2.0
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

    /* 
    IO in/out/oeb is split like this:
    io_oeb is 'output enable bar': low means a pin is an output

    37:32 control
    31:24 user in/out
    23:16 user out
    15:06 user in
    05:04 clock

    */

    // loop back dedicated outs to ins
    assign io_in[15:8] = io_out[23:16];

    // loop back bidirectional outs to ins, depending on output enable
    assign io_in[31:24] = io_out[31:24] & (~io_oeb[31:24]);


endmodule // tt_formal
