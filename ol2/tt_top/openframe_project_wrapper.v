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
    inout vdda,     // User area 0 3.3V supply
    inout vdda1,    // User area 1 3.3V supply
    inout vdda2,    // User area 2 3.3V supply
    inout vssa,     // User area 0 analog ground
    inout vssa1,    // User area 1 analog ground
    inout vssa2,    // User area 2 analog ground
    inout vccd,     // Common 1.8V supply
    inout vccd1,    // User area 1 1.8V supply
    inout vccd2,    // User area 2 1.8v supply
    inout vssd,     // Common digital ground
    inout vssd1,    // User area 1 digital ground
    inout vssd2,    // User area 2 digital ground
    inout vddio,    // Common 3.3V ESD supply
    inout vssio,    // Common ESD ground
`endif

    /* Signals exported from the frame area to the user project */
    /* The user may elect to use any of these inputs. */

    input     porb_h,       // power-on reset, sense inverted, 3.3V domain
    input     porb_l,       // power-on reset, sense inverted, 1.8V domain
    input     por_l,        // power-on reset, noninverted, 1.8V domain
    input     resetb_h,     // master reset, sense inverted, 3.3V domain
    input     resetb_l,     // master reset, sense inverted, 1.8V domain
    input [31:0] mask_rev,  // 32-bit user ID, 1.8V domain

    /* GPIOs.  There are 44 GPIOs (19 left, 19 right, 6 bottom). */
    /* These must be configured appropriately by the user project. */

    /* Basic bidirectional I/O.  Input gpio_in_h is in the 3.3V domain;  all
     * others are in the 1.8v domain.  OEB is output enable, sense inverted.
     */
    input  [`OPENFRAME_IO_PADS-1:0] gpio_in,
    input  [`OPENFRAME_IO_PADS-1:0] gpio_in_h,
    output [`OPENFRAME_IO_PADS-1:0] gpio_out,
    output [`OPENFRAME_IO_PADS-1:0] gpio_oeb,
    output [`OPENFRAME_IO_PADS-1:0] gpio_inp_dis,  // a.k.a. ieb

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

    wire k_zero;
    wire k_one;

	tt_top top_I (
		.io_ana      (analog_io[37:0]),
		.io_in       (gpio_in[37:0]),
		.io_out      (gpio_out[37:0]),
		.io_oeb      (gpio_oeb[37:0]),
		.user_clock2 (k_zero),
		.k_zero      (k_zero),
		.k_one       (k_one)
	);

    tt_autosel autosel_I (
        .clk(gpio_in[41]),
        .rst_n(resetb_l),

        // I2C master interface
        .scl_i(gpio_in[42]),
        .sda_i(gpio_in[43]),
        .scl_o(gpio_out[42]),
        .scl_oe_n(gpio_oeb[42]),
        .sda_o(gpio_out[43]),
        .sda_oe_n(gpio_oeb[43]),

        // Mux ctrl interface
        .ctrl_sel_rst_n(gpio_out[38]),
        .ctrl_sel_inc(gpio_out[39]),
        .ctrl_ena(gpio_out[40])
    );

    /* NOTE:  Openframe signals not used in this project: */
    /* porb_h:    3.3V domain signal                      */
    /* resetb_h:  3.3V domain signal                      */
    /* gpio_in_h: 3.3V domain signals                     */
    /* analog_noesd_io: analog signals                    */

    // -- IO pin configuration --

    // Based on https://github.com/RTimothyEdwards/caravel_openframe_project/blob/afc3ff66b657b3758690c12b077f9a175acf701c/verilog/rtl/picosoc.v#L482-L502:
    // - dm='b000 analog only
    // - dm='b001 for input only
    // - dm='b110 for output (oeb must be set to 0)
    // - dm='b111 for 5k pull-up / pull down (oeb must be set to 0, out 0 for pull-down, out 1 for pull-up)
    // - gpio_ib_mode_sel, gpio_vtrip_sel, gpio_slow_sel are always zero

    // Disable input on pins 0 through 5 (unused):
    assign gpio_inp_dis[5:0] = gpio_loopback_one[5:0];
    assign gpio_dm2[5:0] = gpio_loopback_zero[5:0];
    assign gpio_dm1[5:0] = gpio_loopback_zero[5:0];
    assign gpio_dm0[5:0] = gpio_loopback_zero[5:0];

    // Input on pins 6 through 15 (pad_ui_in):
    assign gpio_inp_dis[15:6] = gpio_loopback_zero[15:6];
    assign gpio_dm2[15:6] = gpio_loopback_zero[15:6];
    assign gpio_dm1[15:6] = gpio_loopback_zero[15:6];
    assign gpio_dm0[15:6] = gpio_loopback_one[15:6];

    // Output-only on pins 16 through 23 (pad_uo_out):
    assign gpio_inp_dis[23:16] = gpio_loopback_one[23:16];
    assign gpio_dm2[23:16] = gpio_loopback_one[23:16];
    assign gpio_dm1[23:16] = gpio_loopback_one[23:16];
    assign gpio_dm0[23:16] = gpio_loopback_zero[23:16];

    // Enable input and output on pins 24 through 31 (pad_uio):
    assign gpio_inp_dis[31:24] = gpio_loopback_zero[31:24];
    assign gpio_dm2[31:24] = gpio_loopback_one[31:24];
    assign gpio_dm1[31:24] = gpio_loopback_one[31:24];
    assign gpio_dm0[31:24] = gpio_loopback_zero[31:24];

    // ctrl_ena:
    assign gpio_inp_dis[32] = gpio_loopback_zero[32];
    assign gpio_dm2[32] = gpio_loopback_zero[32];
    assign gpio_dm1[32] = gpio_loopback_zero[32];
    assign gpio_dm0[32] = gpio_loopback_one[32];

    // disable input on ua[0]:
    assign gpio_inp_dis[33] = gpio_loopback_one[33];
    assign gpio_dm2[33] = gpio_loopback_zero[33];
    assign gpio_dm1[33] = gpio_loopback_zero[33];
    assign gpio_dm0[33] = gpio_loopback_zero[33];

    // ctrl_sel_inc:
    assign gpio_inp_dis[34] = gpio_loopback_zero[34];
    assign gpio_dm2[34] = gpio_loopback_zero[34];
    assign gpio_dm1[34] = gpio_loopback_zero[34];
    assign gpio_dm0[34] = gpio_loopback_one[34];

    // ua[1]:
    assign gpio_inp_dis[35] = gpio_loopback_one[35];
    assign gpio_dm2[35] = gpio_loopback_zero[35];
    assign gpio_dm1[35] = gpio_loopback_zero[35];
    assign gpio_dm0[35] = gpio_loopback_zero[35];

    // ctrl_sel_rst_n:
    assign gpio_inp_dis[36] = gpio_loopback_zero[36];
    assign gpio_dm2[36] = gpio_loopback_zero[36];
    assign gpio_dm1[36] = gpio_loopback_zero[36];
    assign gpio_dm0[36] = gpio_loopback_one[36];

    // pin 37 is unused:
    assign gpio_inp_dis[37] = gpio_loopback_one[37];
    assign gpio_dm2[37] = gpio_loopback_zero[37];
    assign gpio_dm1[37] = gpio_loopback_zero[37];
    assign gpio_dm0[37] = gpio_loopback_zero[37];

    // pins 38...40 are the outputs of the EEPROM controller:
    assign gpio_inp_dis[40:38] = gpio_loopback_zero[40:38];
    assign gpio_dm2[40:38] = gpio_loopback_one[40:38];
    assign gpio_dm1[40:38] = gpio_loopback_one[40:38];
    assign gpio_dm0[40:38] = gpio_loopback_zero[40:38];

    // pin 41 is the clock input to the EEPROM controller:
    assign gpio_inp_dis[41] = gpio_loopback_zero[41];
    assign gpio_dm2[41] = gpio_loopback_zero[41];
    assign gpio_dm1[41] = gpio_loopback_zero[41];
    assign gpio_dm0[41] = gpio_loopback_one[41];

    // pins 42..43 are the SCL/SDA of the EEPROM controller:
    assign gpio_inp_dis[43:42] = gpio_loopback_zero[43:42];
    assign gpio_dm2[43:42] = gpio_loopback_one[43:42];
    assign gpio_dm1[43:42] = gpio_loopback_one[43:42];
    assign gpio_dm0[43:42] = gpio_loopback_zero[43:42];

    assign gpio_ib_mode_sel = gpio_loopback_zero;
    assign gpio_vtrip_sel = gpio_loopback_zero;
    assign gpio_slow_sel = gpio_loopback_zero;

    /* All analog enable/select/polarity and holdover bits  */
    /* will not be handled in the picosoc module.  Tie      */
    /* each one of them off to the local loopback zero bit. */

    assign gpio_analog_en = gpio_loopback_zero;
    assign gpio_analog_pol = gpio_loopback_zero;
    assign gpio_analog_sel = gpio_loopback_zero;
    assign gpio_holdover = gpio_loopback_zero;

    (* keep *) vccd1_connection vccd1_connection ();
    (* keep *) vssd1_connection vssd1_connection ();

endmodule // openframe_project_wrapper
