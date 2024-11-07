/*
 * tt_ihp_wrapper.v
 *
 * Top level for TT on iHP SG13G2
 *
 * Copyright (c) 2024 Sylvain Munaut <tnt@246tNt.com>
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_ihp_wrapper (
	inout wire [63:0] pad_raw
);

	// Signals
	// -------

	wire k_zero;
	wire k_one;

	wire [47:0] pad_in;
	wire [47:0] pad_out;
	wire [47:0] pad_oex;
	wire [47:0] pad_ana;


	// Main core
	// ---------

	tt_top top_I (
		.io_ana      (pad_ana),
		.io_in       (pad_in),
		.io_out      (pad_out),
		.io_oex      (pad_oex),
		.k_zero      (k_zero),
		.k_one       (k_one)
	);


	// GPIO configuration
	// ------------------

	localparam [15:0] TT_PAD_NC         = 16'b0000000000_00_0000;
	localparam [15:0] TT_PAD_CTRL       = 16'b0000000000_00_1010;
	localparam [15:0] TT_PAD_IN         = 16'b0000000000_00_1010;
	localparam [15:0] TT_PAD_OUT        = 16'b0000000000_00_1001;
	localparam [15:0] TT_PAD_INOUT      = 16'b0000000000_00_1011;
//	localparam [15:0] TT_PAD_ANALOG     = 16'b0000000000_00_1100;
	localparam [15:0] TT_PAD_ANALOG     = TT_PAD_NC; // FIXME
	localparam [15:0] TT_PAD_PWR_CORE   = 16'b0000000000_00_0101;
	localparam [15:0] TT_PAD_GND_CORE   = 16'b0000000000_00_0100;
	localparam [15:0] TT_PAD_PWR_IO     = 16'b0000000000_00_0111;
	localparam [15:0] TT_PAD_GND_IO     = 16'b0000000000_00_0110;
	localparam [15:0] TT_PAD_PWR_ANALOG = TT_PAD_PWR_IO; // FIXME
	localparam [15:0] TT_PAD_GND_ANALOG = TT_PAD_GND_IO; // FIXME

	localparam [64*24-1:0] CONFIG = {
		 8'd0, TT_PAD_PWR_CORE,		// 64 - VDD Core
		 8'd0, TT_PAD_GND_CORE,		// 63 - GND Core
		8'd47, TT_PAD_ANALOG,		// 62 - ana[15]
		8'd46, TT_PAD_ANALOG,		// 61 - ana[14]
		8'd45, TT_PAD_ANALOG,		// 60 - ana[13]
		8'd44, TT_PAD_ANALOG,		// 59 - ana[12]
		 8'd0, TT_PAD_PWR_ANALOG,	// 58 - VDD Analog
		 8'd0, TT_PAD_GND_ANALOG,	// 57 - GND Analog
		8'd43, TT_PAD_ANALOG,		// 56 - ana[11]
		8'd42, TT_PAD_ANALOG,		// 55 - ana[10]
		8'd41, TT_PAD_ANALOG,		// 54 - ana[9]
		8'd40, TT_PAD_ANALOG,		// 53 - ana[8]
		 8'd0, TT_PAD_PWR_IO,		// 52 - VDD IO
		 8'd0, TT_PAD_GND_IO,		// 51 - GND IO
		 8'd6, TT_PAD_IN,			// 50 - u_clk
		 8'd7, TT_PAD_IN,			// 49 - u_rst
		8'd15, TT_PAD_IN,			// 48 - ui[7]
		8'd14, TT_PAD_IN,			// 47 - ui[6]
		8'd13, TT_PAD_IN,			// 46 - ui[5]
		8'd12, TT_PAD_IN,			// 45 - ui[4]
		8'd11, TT_PAD_IN,			// 44 - ui[3]
		8'd10, TT_PAD_IN,			// 43 - ui[2]
		 8'd9, TT_PAD_IN,			// 42 - ui[1]
		 8'd8, TT_PAD_IN,			// 41 - ui[0]
		8'd23, TT_PAD_INOUT,		// 40 - uio[7]
		8'd22, TT_PAD_INOUT,		// 39 - uio[6]
		8'd21, TT_PAD_INOUT,		// 38 - uio[5]
		8'd20, TT_PAD_INOUT,		// 37 - uio[4]
		8'd19, TT_PAD_INOUT,		// 36 - uio[3]
		8'd18, TT_PAD_INOUT,		// 35 - uio[2]
		8'd17, TT_PAD_INOUT,		// 34 - uio[1]
		8'd16, TT_PAD_INOUT,		// 33 - uio[0]
		 8'd0, TT_PAD_PWR_IO,		// 32 - VDD IO
		 8'd0, TT_PAD_GND_IO,		// 31 - GND IO
		 8'd0, TT_PAD_PWR_CORE,		// 30 - VDD Core
		 8'd0, TT_PAD_GND_CORE,		// 29 - GND Core
		8'd39, TT_PAD_ANALOG,		// 28 - ana[7]
		8'd38, TT_PAD_ANALOG,		// 27 - ana[6]
		8'd37, TT_PAD_ANALOG,		// 26 - ana[5]
		8'd36, TT_PAD_ANALOG,		// 25 - ana[4]
		 8'd0, TT_PAD_GND_ANALOG,	// 24 - GND Analog
		 8'd0, TT_PAD_PWR_ANALOG,	// 23 - VAA Analog
		8'd35, TT_PAD_ANALOG,		// 22 - ana[3]
		8'd34, TT_PAD_ANALOG,		// 21 - ana[2]
		8'd33, TT_PAD_ANALOG,		// 20 - ana[1]
		8'd32, TT_PAD_ANALOG,		// 19 - ana[0]
		 8'd0, TT_PAD_GND_IO,		// 18 - GND IO
		 8'd0, TT_PAD_PWR_IO,		// 17 - VDD IO
		8'd31, TT_PAD_OUT,			// 16 - uo[7]
		8'd30, TT_PAD_OUT,			// 15 - uo[6]
		8'd29, TT_PAD_OUT,			// 14 - uo[5]
		8'd28, TT_PAD_OUT,			// 13 - uo[4]
		8'd27, TT_PAD_OUT,			// 12 - uo[3]
		8'd26, TT_PAD_OUT,			// 11 - uo[2]
		8'd25, TT_PAD_OUT,			// 10 - uo[1]
		8'd24, TT_PAD_OUT,			// 9  - uo[0]
		 8'd0, TT_PAD_NC,			// 8  - n/a
		 8'd0, TT_PAD_NC,			// 7  - n/a
		 8'd5, TT_PAD_IN,			// 6  - ctl[5]
		 8'd4, TT_PAD_IN,			// 5  - ctl[4]
		 8'd3, TT_PAD_IN,			// 4  - ctl[3]
		 8'd2, TT_PAD_IN,			// 3  - ctl[2]
		 8'd1, TT_PAD_IN,			// 2  - ctl[1]
		 8'd0, TT_PAD_IN			// 1  - ctl[0]
	};

	genvar i;
	for (i=0; i<64; i=i+1)
	begin : gpio
		localparam [23:0] PAD_CFG = CONFIG[24*i+:24];

		tt_ihp_gpio #(
			.CONFIG(PAD_CFG[15:0])
		) gpio_I (
			.pad_ana (pad_ana[PAD_CFG[23:16]]),
			.pad_in  (pad_in[PAD_CFG[23:16]]),
			.pad_out (pad_out[PAD_CFG[23:16]]),
			.pad_oe  (pad_oex[PAD_CFG[23:16]]),
			.pad_raw (pad_raw[i])
		);
	end

endmodule	// tt_ihp_wrapper
