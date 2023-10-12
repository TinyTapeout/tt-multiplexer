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
`define MPRJ_IO_PADS 38

/*
 *-------------------------------------------------------------
 *
 * user_project_wrapper
 *
 * This wrapper enumerates all of the pins available to the
 * user for the user project.
 *
 * An example user project is provided in this wrapper.  The
 * example should be removed and replaced with the actual
 * user project.
 *
 * THIS FILE HAS BEEN GENERATED USING multi_tools_project CODEGEN
 * IF YOU NEED TO MAKE EDITS TO IT, EDIT codegen/caravel_iface_header.txt
 *
 *-------------------------------------------------------------
 */

module user_project_wrapper (
`ifdef USE_POWER_PINS
	inout vdda1,       // User area 1 3.3V supply
	inout vdda2,       // User area 2 3.3V supply
	inout vssa1,       // User area 1 analog ground
	inout vssa2,       // User area 2 analog ground
	inout vccd1,       // User area 1 1.8V supply
	inout vccd2,       // User area 2 1.8v supply
	inout vssd1,       // User area 1 digital ground
	inout vssd2,       // User area 2 digital ground
`endif

	// Wishbone Slave ports (WB MI A)
	input  wire        wb_clk_i,
	input  wire        wb_rst_i,
	input  wire        wbs_stb_i,
	input  wire        wbs_cyc_i,
	input  wire        wbs_we_i,
	input  wire  [3:0] wbs_sel_i,
	input  wire [31:0] wbs_dat_i,
	input  wire [31:0] wbs_adr_i,
	output wire        wbs_ack_o,
	output wire [31:0] wbs_dat_o,

	// Logic Analyzer Signals
	input  wire [127:0] la_data_in,
	output wire [127:0] la_data_out,
	input  wire [127:0] la_oenb,

	// IOs
	input  wire [`MPRJ_IO_PADS-1:0] io_in,
	output wire [`MPRJ_IO_PADS-1:0] io_out,
	output wire [`MPRJ_IO_PADS-1:0] io_oeb,

	// Analog (direct connection to GPIO pad---use with caution)
	// Note that analog I/O is not available on the 7 lowest-numbered
	// GPIO pads, and so the analog_io indexing is offset from the
	// GPIO indexing by 7 (also upper 2 GPIOs do not have analog_io).
	inout  wire [`MPRJ_IO_PADS-10:0] analog_io,

	// Independent clock (on independent integer divider)
	input  wire user_clock2,

	// User maskable interrupt signals
	output wire [2:0] user_irq
);

	// Signals
	wire k_zero;
	wire k_one;

	wire [37:0] io_ana;

	// Main core
	tt_top top_I (
`ifdef USE_POWER_PINS
		.VPWR        (vccd1),
		.VGND        (vssd1),
`endif
		.io_ana      (io_ana),
		.io_in       (io_in),
		.io_out      (io_out),
		.io_oeb      (io_oeb),
		.user_clock2 (user_clock2),
		.k_zero      (k_zero),
		.k_one       (k_one)
	);

	// Map analog "range"
	assign io_ana[35:7] = analog_io;

	// Tie-offs
	assign wbs_ack_o = k_zero;
	assign wbs_dat_o = {32{k_zero}};

	assign la_data_out = {128{k_zero}};

	assign user_irq = {3{k_zero}};

endmodule	// user_project_wrapper
`default_nettype wire
