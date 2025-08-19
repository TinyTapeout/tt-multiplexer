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
	 *        1111 VDD Analog
	 *        1110 GND Analog
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

		case (1)

		/* IOPadVss */
		(MODE == 4'b0100):
		begin
			(* keep *)
			sg13cmos5l_IOPadVss pad_I();
		end

		/* IOPadVdd */
		(MODE == 4'b0101):
		begin
			(* keep *)
			sg13cmos5l_IOPadVdd pad_I();
		end

		/* IOPadIOVss */
		(MODE == 4'b0110):
		begin
			(* keep *)
			sg13cmos5l_IOPadIOVss pad_I();
		end

		/* IOPadIOVdd */
		(MODE == 4'b0111):
		begin
			(* keep *)
			sg13cmos5l_IOPadIOVdd pad_I();
		end

		/* Digital Output */
			/* 4 mA */
		((MODE == 4'b1001) && (DRIVE_STRENGTH == 0)):
		begin
			(* keep *)
			sg13cmos5l_IOPadOut4mA pad_I (
				.c2p    (pad_out),
				.pad    (pad_raw)
			);
		end

			/* 16 mA */
		((MODE == 4'b1001) && (DRIVE_STRENGTH == 1)):
		begin
			(* keep *)
			sg13cmos5l_IOPadOut16mA pad_I (
				.c2p    (pad_out),
				.pad    (pad_raw)
			);
		end

			/* 30 mA */
		((MODE == 4'b1001) && (DRIVE_STRENGTH == 2)):
		begin
			(* keep *)
			sg13cmos5l_IOPadOut30mA pad_I (
				.c2p    (pad_out),
				.pad    (pad_raw)
			);
		end

		/* Digital Input */
		(MODE == 4'b1010):
		begin
			(* keep *)
			sg13cmos5l_IOPadIn pad_I (
				.p2c  (pad_in),
				.pad  (pad_raw)
			);
		end

		/* Digital IO */
			/* 4 mA */
		((MODE == 4'b1011) && (DRIVE_STRENGTH == 0)):
		begin
			(* keep *)
			sg13cmos5l_IOPadInOut4mA pad_I (
				.c2p    (pad_out),
				.c2p_en (pad_oe),
				.p2c    (pad_in),
				.pad    (pad_raw)
			);
		end

		/* 16 mA */
		((MODE == 4'b1011) && (DRIVE_STRENGTH == 1)):
		begin

			(* keep *)
			sg13cmos5l_IOPadInOut16mA pad_I (
				.c2p    (pad_out),
				.c2p_en (pad_oe),
				.p2c    (pad_in),
				.pad    (pad_raw)
			);
		end

		/* 30 mA */
		((MODE == 4'b1011) && (DRIVE_STRENGTH == 2)):
		begin
			(* keep *)
			sg13cmos5l_IOPadInOut30mA pad_I (
				.c2p    (pad_out),
				.c2p_en (pad_oe),
				.p2c    (pad_in),
				.pad    (pad_raw)
			);
		end

		/* Analog */
		(MODE == 4'b1100):
		begin
			(* keep *)
			sg13cmos5l_IOPadAnalog pad_I (
				.pad    (pad_raw),
				.padres ()
			);

			(* keep *)
			tt_ckt_ana ckt_I (
				.pad    (pad_raw),
				.analog (pad_ana)
			);
		end

		/* VDD Analog */
		(MODE == 4'b1111):
		begin
			(* keep *)
			sg13cmos5l_IOPadAnalog pad_I (
				.pad    (), /* Connected later */
				.padres ()
			);
		end

		/* GND Analog */
		(MODE == 4'b1110):
		begin
			(* keep *)
			sg13cmos5l_IOPadVss pad_I();
		end

		endcase

	endgenerate

endmodule // tt_ihp_gpio

