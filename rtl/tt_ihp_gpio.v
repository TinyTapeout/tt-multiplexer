/*
 * tt_ihp_gpio.v
 *
 * GPIO block
 *
 * Handles the interface between the actual pad frame and
 * the controller
 *
 * Copyright (c) 2024 Sylvain Munaut <tnt@246tNt.com>
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_ihp_gpio #(
	parameter [15:0] CONFIG = 16'h0000
	/*
     *  [5:4] Drive Strength
     *
     *        10   30 mA
     *        01   16 mA
     *        00    4 mA
     *
     *  [3:0] Mode
     *
     *        1100 Analog
     *
     *        1011 Digital IO
     *        1010 Digital Input
     *        1001 Digital Output
     *
     *        0111 IOPadIOVdd
     *        0110 IOPadIOVss
     *        0101 IOPadVdd
     *        0100 IOPadVss
     *
     *        0000 nc
	 */

)(
	// Connection to controller
	inout  wire pad_ana,
	output wire pad_in,
	input  wire pad_out,
	input  wire pad_oe,

	// Actual pad
	inout  wire pad_raw
);

	parameter integer MODE = CONFIG & 15;
	parameter integer DRIVE_STRENGTH = (CONFIG >> 4) & 3;

	generate

     	/* IOPadVss */
		if (MODE == 4'b0100) begin

			(* keep *)
			sg13g2_IOPadVss pad_I();

		/* IOPadVdd */
		end else if (MODE == 4'b0101) begin

			(* keep *)
			sg13g2_IOPadVdd pad_I();

		/* IOPadIOVss */
		end else if (MODE == 4'b0110) begin

			(* keep *)
			sg13g2_IOPadIOVss pad_I();

		/* IOPadIOVdd */
		end else if (MODE == 4'b0111) begin

			(* keep *)
			sg13g2_IOPadIOVdd pad_I();

		/* Digital Output */
		end else if (MODE == 4'b1001) begin

			/* 4 mA */
			if (DRIVE_STRENGTH == 0) begin

				(* keep *)
				sg13g2_IOPadOut4mA pad_I (
					.c2p    (pad_out),
					.pad    (pad_raw)
				);

			/* 16 mA */
			end  if (DRIVE_STRENGTH == 1) begin

				(* keep *)
				sg13g2_IOPadOut16mA pad_I (
					.c2p    (pad_out),
					.pad    (pad_raw)
				);

			/* 30 mA */
			end  if (DRIVE_STRENGTH == 2) begin

				(* keep *)
				sg13g2_IOPadOut30mA pad_I (
					.c2p    (pad_out),
					.pad    (pad_raw)
				);

			end

		/* Digital Input */
		end else if (MODE == 4'b1010) begin

			(* keep *)
			sg13g2_IOPadIn pad_I (
				.p2c  (pad_in),
				.pad  (pad_raw)
			);

		/* Digital IO */
		end else if (MODE == 4'b1011) begin

			/* 4 mA */
			if (DRIVE_STRENGTH == 0) begin

				(* keep *)
				sg13g2_IOPadInOut4mA pad_I (
					.c2p    (pad_out),
					.c2p_en (pad_oe),
					.p2c    (pad_in),
					.pad    (pad_raw)
				);

			/* 16 mA */
			end  if (DRIVE_STRENGTH == 1) begin

				(* keep *)
				sg13g2_IOPadInOut16mA pad_I (
					.c2p    (pad_out),
					.c2p_en (pad_oe),
					.p2c    (pad_in),
					.pad    (pad_raw)
				);

			/* 30 mA */
			end  if (DRIVE_STRENGTH == 2) begin

				(* keep *)
				sg13g2_IOPadInOut30mA pad_I (
					.c2p    (pad_out),
					.c2p_en (pad_oe),
					.p2c    (pad_in),
					.pad    (pad_raw)
				);

			end

		/* Analog */
		end else if (MODE == 4'b1100) begin

			(* keep *)
			sg13g2_IOPadAnalog pad_I (
				.pad    (pad_ana),
				.padres ()
			);

			assign pad_raw = pad_ana;
			assign pad_ana = pad_raw;

		end

	endgenerate

endmodule // tt_ihp_gpio

