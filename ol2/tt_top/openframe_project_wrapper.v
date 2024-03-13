// SPDX-FileCopyrightText: 2020 Efabless Corporation
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0

`default_nettype none
`define OPENFRAME_IO_PADS 44

/*
 *-------------------------------------------------------------
 *
 * openframe_project_wrapper
 *
 * This wrapper enumerates all of the pins available to the
 * user for the user openframe project.
 *
 * Written by Tim Edwards
 * March 27, 2023
 * Efabless Corporation
 *
 *-------------------------------------------------------------
 */

module openframe_project_wrapper (
`ifdef USE_POWER_PINS
    inout vdda,		// User area 0 3.3V supply
    inout vdda1,	// User area 1 3.3V supply
    inout vdda2,	// User area 2 3.3V supply
    inout vssa,		// User area 0 analog ground
    inout vssa1,	// User area 1 analog ground
    inout vssa2,	// User area 2 analog ground
    inout vccd,		// Common 1.8V supply
    inout vccd1,	// User area 1 1.8V supply
    inout vccd2,	// User area 2 1.8v supply
    inout vssd,		// Common digital ground
    inout vssd1,	// User area 1 digital ground
    inout vssd2,	// User area 2 digital ground
`endif

    /* Signals exported from the frame area to the user project */
    /* The user may elect to use any of these inputs.		*/

    input	 porb_h,	// power-on reset, sense inverted, 3.3V domain
    input	 porb_l,	// power-on reset, sense inverted, 1.8V domain
    input	 por_l,		// power-on reset, noninverted, 1.8V domain
    input	 resetb_h,	// master reset, sense inverted, 3.3V domain
    input	 resetb_l,	// master reset, sense inverted, 1.8V domain
    input [31:0] mask_rev,	// 32-bit user ID, 1.8V domain

    /* GPIOs.  There are 44 GPIOs (19 left, 19 right, 6 bottom). */
    /* These must be configured appropriately by the user project. */

    /* Basic bidirectional I/O.  Input gpio_in_h is in the 3.3V domain;  all
     * others are in the 1.8v domain.  OEB is output enable, sense inverted.
     */
    input  [`OPENFRAME_IO_PADS-1:0] gpio_in,
    input  [`OPENFRAME_IO_PADS-1:0] gpio_in_h,
    output [`OPENFRAME_IO_PADS-1:0] gpio_out,
    output [`OPENFRAME_IO_PADS-1:0] gpio_oeb,
    output [`OPENFRAME_IO_PADS-1:0] gpio_inp_dis,	// a.k.a. ieb

    /* Pad configuration.  These signals are usually static values.
     * See the documentation for the sky130_fd_io__gpiov2 cell signals
     * and their use.
     */
    output [`OPENFRAME_IO_PADS-1:0] gpio_ib_mode_sel,
    output [`OPENFRAME_IO_PADS-1:0] gpio_vtrip_sel,
    output [`OPENFRAME_IO_PADS-1:0] gpio_slow_sel,
    output [`OPENFRAME_IO_PADS-1:0] gpio_holdover,
    output [`OPENFRAME_IO_PADS-1:0] gpio_analog_en,
    output [`OPENFRAME_IO_PADS-1:0] gpio_analog_sel,
    output [`OPENFRAME_IO_PADS-1:0] gpio_analog_pol,
    output [`OPENFRAME_IO_PADS-1:0] gpio_dm2,
    output [`OPENFRAME_IO_PADS-1:0] gpio_dm1,
    output [`OPENFRAME_IO_PADS-1:0] gpio_dm0,

    /* These signals correct directly to the pad.  Pads using analog I/O
     * connections should keep the digital input and output buffers turned
     * off.  Both signals connect to the same pad.  The "noesd" signal
     * is a direct connection to the pad;  the other signal connects through
     * a series resistor which gives it minimal ESD protection.  Both signals
     * have basic over- and under-voltage protection at the pad.  These
     * signals may be expected to attenuate heavily above 50MHz.
     */
    inout  [`OPENFRAME_IO_PADS-1:0] analog_io,
    inout  [`OPENFRAME_IO_PADS-1:0] analog_noesd_io,

    /* These signals are constant one and zero in the 1.8V domain, one for
     * each GPIO pad, and can be looped back to the control signals on the
     * same GPIO pad to set a static configuration at power-up.
     */
    input  [`OPENFRAME_IO_PADS-1:0] gpio_loopback_one,
    input  [`OPENFRAME_IO_PADS-1:0] gpio_loopback_zero
);

	// Signals
	// -------

	wire k_zero;
	wire k_one;


	// Main core
	// ---------

	tt_top top_I (
`ifdef USE_POWER_PINS
		.VPWR        (vccd1),
		.VGND        (vssd1),
`endif
		.io_ana      (analog_io),
		.io_in       (gpio_in),
		.io_out      (gpio_out),
		.io_oeb      (gpio_oeb),
		.k_zero      (k_zero),
		.k_one       (k_one)
	);


	// GPIO configuration
	// ------------------

	// FIXME
//	assign gpio_inp_dis     = gpio_loopback_zero;
//	assign gpio_ib_mode_sel = gpio_loopback_zero;
//	assign gpio_vtrip_sel   = gpio_loopback_zero;
//	assign gpio_slow_sel    = gpio_loopback_zero;
//	assign gpio_holdover    = gpio_loopback_zero;
//	assign gpio_analog_en   = gpio_loopback_zero;
//	assign gpio_analog_sel  = gpio_loopback_zero;
//	assign gpio_analog_pol  = gpio_loopback_zero;
//	assign gpio_dm2         = gpio_loopback_zero;
//	assign gpio_dm1         = gpio_loopback_zero;
//	assign gpio_dm0         = gpio_loopback_zero;
	assign gpio_inp_dis     = {44{k_zero}};
	assign gpio_ib_mode_sel = {44{k_zero}};
	assign gpio_vtrip_sel   = {44{k_zero}};
	assign gpio_slow_sel    = {44{k_zero}};
	assign gpio_holdover    = {44{k_zero}};
	assign gpio_analog_en   = {44{k_zero}};
	assign gpio_analog_sel  = {44{k_zero}};
	assign gpio_analog_pol  = {44{k_zero}};
	assign gpio_dm2         = {44{k_zero}};
	assign gpio_dm1         = {44{k_zero}};
	assign gpio_dm0         = {44{k_zero}};

endmodule	// openframe_project_wrapper
