/*
 * tt_gf_gpio.v
 *
 * GPIO block
 *
 * Handles the interface between the actual pad frame and
 * the controller
 *
 * Copyright (c) 2025 Sylvain Munaut <tnt@246tNt.com>
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_gf_gpio #(
	parameter [15:0] CONFIG = 16'h0000
	/*
	 *  [10]  Input Type
	 *
	 *        0  CMOS Buffer
	 *        1  Schmitt Trigger
	 *
	 *  [9]   Pull-Up   enable
	 *  [8]   Pull-Down enable
	 *
	 *  [7]   Slew Control
	 *
	 *        0  Fast
	 *        1  Slow
	 *
     *  [6:4] Drive Strength
     *
     *        100   24 mA
     *        011   16 mA
     *        010   12 mA
     *        001    8 mA
     *        000    4 mA
     *
     *  [3:0] Mode
     *
     *        1111 Analog
	 *        1101 VDD Analog
	 *        1100 GND Analog
	 *
     *        1011 VDD IO
     *        1010 GND IO
     *        1001 VDD Core
     *        1000 GND Core
     *
     *        0111 Digital IO
     *        0110 Digital Output
     *        0101 Digital Input
	 *
     *        0000 nc
	 */

)(
	// Power rails
`ifdef USE_POWER_PINS
	inout  wire DVDD,
	inout  wire DVSS,

	inout  wire VDPWR,
	inout  wire VAPWR,
	input  wire VGND,
`endif

	// Constants
	input  wire k_zero,
	input  wire k_one,

	// Connection to controller
	inout  wire pad_ana,
	output wire pad_in,
	input  wire pad_out,
	input  wire pad_oe,

	// Actual pad
	inout  wire pad_raw
);

	parameter integer MODE           =  CONFIG        & 15;
	parameter integer DRIVE_STRENGTH = (CONFIG >>  4) &  7;
	parameter integer SLEW_RATE      = (CONFIG >>  7) &  1;
	parameter integer PD_ENABLE      = (CONFIG >>  8) &  1;
	parameter integer PU_ENABLE      = (CONFIG >>  9) &  1;
	parameter integer INPUT_TYPE     = (CONFIG >> 10) &  1;


	wire l_pd = PD_ENABLE ? k_one : k_zero;
	wire l_pu = PU_ENABLE ? k_one : k_zero;


	generate

		case (1)

		(MODE == 4'b0000): /* NC */
		begin
			(* keep *)
			gf180mcu_fd_io__asig_5p0 pad_I (
`ifdef USE_POWER_PINS
				.DVDD   (DVDD),
				.DVSS   (DVSS),
				.VDD    (VDPWR),
				.VSS    (VGND),
`endif
				.ASIG5V ()
			);
		end

		(MODE == 4'b1111): /* Analog */
		begin
			(* keep *)
			gf180mcu_fd_io__asig_5p0 pad_I (
`ifdef USE_POWER_PINS
				.DVDD   (DVDD),
				.DVSS   (DVSS),
				.VDD    (VDPWR),
				.VSS    (VGND),
`endif
				.ASIG5V (pad_raw)
			);

			assign pad_raw = pad_ana;
			assign pad_ana = pad_raw;
		end

		(MODE == 4'b1101): /* VDD Analog */
		begin
			(* keep *)
			gf180mcu_fd_io__dvdd pad_I (
`ifdef USE_POWER_PINS
				.DVDD   (DVDD),
				.DVSS   (DVSS),
				.VSS    (VGND)
`endif
			);
		end

		(MODE == 4'b1100): /* GND Analog */
		begin
			(* keep *)
			gf180mcu_fd_io__dvss pad_I (
`ifdef USE_POWER_PINS
				.DVDD   (DVDD),
				.DVSS   (DVSS),
				.VDD    (VDPWR)
`endif
			);
		end

		(MODE == 4'b1011): /* VDD IO */
		begin
			(* keep *)
			gf180mcu_fd_io__dvdd pad_I (
`ifdef USE_POWER_PINS
				.DVDD   (DVDD),
				.DVSS   (DVSS),
				.VSS    (VGND)
`endif
			);
		end

		(MODE == 4'b1010): /* GND IO */
		begin
			(* keep *)
			gf180mcu_fd_io__dvss pad_I (
`ifdef USE_POWER_PINS
				.DVDD   (DVDD),
				.DVSS   (DVSS),
				.VDD    (VDPWR)
`endif
			);
		end

		(MODE == 4'b1001): /* VDD Core */
		begin
			(* keep *)
			gf180mcu_fd_io__dvdd pad_I (
`ifdef USE_POWER_PINS
				.DVDD   (DVDD),
				.DVSS   (DVSS),
				.VSS    (VGND)
`endif
			);
		end

		(MODE == 4'b1000): /* GND Core */
		begin
			(* keep *)
			gf180mcu_fd_io__dvss pad_I (
`ifdef USE_POWER_PINS
				.DVDD   (DVDD),
				.DVSS   (DVSS),
				.VDD    (VDPWR)
`endif
			);
		end

		((MODE[3:1] == 3'b011) && (DRIVE_STRENGTH[2] == 1'b0)):	/* Digital IO/Output 4~16mA */
		begin

			wire l_cs = MODE      ? k_one : k_zero;
			wire l_sl = SLEW_RATE ? k_one : k_zero;
			wire l_ie = MODE[0]   ? k_one : k_zero;

			wire l_pdrv1 = DRIVE_STRENGTH[1] ? k_one : k_zero;
			wire l_pdrv0 = DRIVE_STRENGTH[0] ? k_one : k_zero;

			(* keep *)
			gf180mcu_fd_io__bi_t pad_I (
`ifdef USE_POWER_PINS
				.DVDD   (DVDD),
				.DVSS   (DVSS),
				.VDD    (VDPWR),
				.VSS    (VGND),
`endif
				.A      (pad_out),
				.OE     (pad_oe),
				.Y      (pad_in),
				.PAD    (pad_raw),
				.PDRV0  (l_pdrv0),
				.PDRV1  (l_pdrv1),
				.CS     (l_cs),
				.SL     (l_sl),
				.IE     (l_ie),
				.PU     (l_pu),
				.PD     (l_pd)
			);

		end

		((MODE[3:1] == 3'b011) && (DRIVE_STRENGTH[2] == 1'b1)):	/* Digital IO/Output 24mA */
		begin

			wire l_cs = MODE      ? k_one : k_zero;
			wire l_sl = SLEW_RATE ? k_one : k_zero;
			wire l_ie = MODE[0]   ? k_one : k_zero;

			(* keep *)
			gf180mcu_fd_io__bi_24t pad_I (
`ifdef USE_POWER_PINS
				.DVDD   (DVDD),
				.DVSS   (DVSS),
				.VDD    (VDPWR),
				.VSS    (VGND),
`endif
				.A      (pad_out),
				.OE     (pad_oe),
				.Y      (pad_in),
				.PAD    (pad_raw),
				.CS     (l_cs),
				.SL     (l_sl),
				.IE     (l_ie),
				.PU     (l_pu),
				.PD     (l_pd)
			);

		end

		((MODE == 4'b0101) && (INPUT_TYPE == 1'b0)): /* Digital Input - CMOS */
		begin

			(* keep *)
			gf180mcu_fd_io__in_c pad_I (
`ifdef USE_POWER_PINS
				.DVDD   (DVDD),
				.DVSS   (DVSS),
				.VDD    (VDPWR),
				.VSS    (VGND),
`endif
				.Y      (pad_in),
				.PAD    (pad_raw),
				.PU     (l_pu),
				.PD     (l_pd)
			);

		end

		((MODE == 4'b0101) && (INPUT_TYPE == 1'b1)): /* Digital Input - Schmitt */
		begin

			(* keep *)
			gf180mcu_fd_io__in_s pad_I (
`ifdef USE_POWER_PINS
				.DVDD   (DVDD),
				.DVSS   (DVSS),
				.VDD    (VDPWR),
				.VSS    (VGND),
`endif
				.Y      (pad_in),
				.PAD    (pad_raw),
				.PU     (l_pu),
				.PD     (l_pd)
			);

		end

		endcase

	endgenerate

endmodule // tt_gf_gpio

