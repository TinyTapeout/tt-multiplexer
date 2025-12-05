/*
 * tt_gf_wrapper.v
 *
 * Top level for TT on gf180mcuD
 *
 * Copyright (c) 2025 Sylvain Munaut <tnt@246tNt.com>
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_gf_wrapper (
	inout wire [73:0] pad_raw
);

	// Signals
	// -------

	wire dvdd;
	wire dvss;
	wire vdpwr;
	wire vapwr;
	wire vgnd;

	wire k_zero;
	wire k_one;

	wire [53:0] pad_in;
	wire [53:0] pad_out;
	wire [53:0] pad_oex;
	wire [53:0] pad_ana;


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

	localparam [15:0] TT_PAD_NC         = 16'b00000_0_00_0_000_0000;

	localparam [15:0] TT_PAD_CTRL       = 16'b00000_1_01_0_000_0101;
	localparam [15:0] TT_PAD_IN         = 16'b00000_0_00_0_000_0101;
	localparam [15:0] TT_PAD_OUT        = 16'b00000_0_00_0_100_0110;
	localparam [15:0] TT_PAD_INOUT      = 16'b00000_0_00_0_100_0111;
	localparam [15:0] TT_PAD_ANALOG     = 16'b00000_0_00_0_000_1111;
	localparam [15:0] TT_PAD_PWR_CORE   = 16'b00000_0_00_0_000_1001;
	localparam [15:0] TT_PAD_GND_CORE   = 16'b00000_0_00_0_000_1000;
	localparam [15:0] TT_PAD_PWR_IO     = 16'b00000_0_00_0_000_1011;
	localparam [15:0] TT_PAD_GND_IO     = 16'b00000_0_00_0_000_1010;
	localparam [15:0] TT_PAD_PWR_ANALOG = 16'b00000_0_00_0_000_0000;	// NC
	localparam [15:0] TT_PAD_GND_ANALOG = 16'b00000_0_00_0_000_1000;

	localparam [74*24-1:0] CONFIG = {
		8'd0,	TT_PAD_PWR_IO,		/* [73] VDD IO */
		8'd0,	TT_PAD_GND_IO,		/* [72] GND IO */
		8'd0,	TT_PAD_PWR_CORE,	/* [71] VDD Core */
		8'd0,	TT_PAD_GND_CORE,	/* [70] GND Core */
		8'd53,	TT_PAD_ANALOG,		/* [69] analog[21] */
		8'd52,	TT_PAD_ANALOG,		/* [68] analog[20] */
		8'd51,	TT_PAD_ANALOG,		/* [67] analog[19] */
		8'd50,	TT_PAD_ANALOG,		/* [66] analog[18] */
		8'd49,	TT_PAD_ANALOG,		/* [65] analog[17] */
		8'd48,	TT_PAD_ANALOG,		/* [64] analog[16] */
		8'd0,	TT_PAD_PWR_ANALOG,	/* [63] VDD Analog */
		8'd0,	TT_PAD_GND_ANALOG,	/* [62] GND Analog */
		8'd47,	TT_PAD_ANALOG,		/* [61] analog[15] */
		8'd46,	TT_PAD_ANALOG,		/* [60] analog[14] */
		8'd45,	TT_PAD_ANALOG,		/* [59] analog[13] */
		8'd44,	TT_PAD_ANALOG,		/* [58] analog[12] */
		8'd0,	TT_PAD_PWR_IO,		/* [57] VDD IO */
		8'd0,	TT_PAD_GND_IO,		/* [56] GND IO */
		8'd6,	TT_PAD_IN,			/* [55] u_clk */
		8'd7,	TT_PAD_IN,			/* [54] u_rst_n */
		8'd15,	TT_PAD_IN,			/* [53] ui[7] */
		8'd14,	TT_PAD_IN,			/* [52] ui[6] */
		8'd13,	TT_PAD_IN,			/* [51] ui[5] */
		8'd12,	TT_PAD_IN,			/* [50] ui[4] */
		8'd11,	TT_PAD_IN,			/* [49] ui[3] */
		8'd10,	TT_PAD_IN,			/* [48] ui[2] */
		8'd9,	TT_PAD_IN,			/* [47] ui[1] */
		8'd8,	TT_PAD_IN,			/* [46] ui[0] */
		8'd0,	TT_PAD_GND_IO,		/* [45] GND IO */
		8'd23,	TT_PAD_INOUT,		/* [44] uio[7] */
		8'd22,	TT_PAD_INOUT,		/* [43] uio[6] */
		8'd21,	TT_PAD_INOUT,		/* [42] uio[5] */
		8'd20,	TT_PAD_INOUT,		/* [41] uio[4] */
		8'd19,	TT_PAD_INOUT,		/* [40] uio[3] */
		8'd18,	TT_PAD_INOUT,		/* [39] uio[2] */
		8'd17,	TT_PAD_INOUT,		/* [38] uio[1] */
		8'd16,	TT_PAD_INOUT,		/* [37] uio[0] */
		8'd0,	TT_PAD_PWR_IO,		/* [36] VDD IO */
		8'd0,	TT_PAD_GND_IO,		/* [35] GND IO */
		8'd0,	TT_PAD_PWR_CORE,	/* [34] VDD Core */
		8'd0,	TT_PAD_GND_CORE,	/* [33] GND Core */
		8'd43,	TT_PAD_ANALOG,		/* [32] analog[11] */
		8'd42,	TT_PAD_ANALOG,		/* [31] analog[10] */
		8'd41,	TT_PAD_ANALOG,		/* [30] analog[9] */
		8'd40,	TT_PAD_ANALOG,		/* [29] analog[8] */
		8'd39,	TT_PAD_ANALOG,		/* [28] analog[7] */
		8'd38,	TT_PAD_ANALOG,		/* [27] analog[6] */
		8'd0,	TT_PAD_GND_ANALOG,	/* [26] GND Analog */
		8'd0,	TT_PAD_PWR_ANALOG,	/* [25] VDD Analog */
		8'd37,	TT_PAD_ANALOG,		/* [24] analog[5] */
		8'd36,	TT_PAD_ANALOG,		/* [23] analog[4] */
		8'd35,	TT_PAD_ANALOG,		/* [22] analog[3] */
		8'd34,	TT_PAD_ANALOG,		/* [21] analog[2] */
		8'd33,	TT_PAD_ANALOG,		/* [20] analog[1] */
		8'd32,	TT_PAD_ANALOG,		/* [19] analog[0] */
		8'd0,	TT_PAD_GND_IO,		/* [18] GND IO */
		8'd0,	TT_PAD_PWR_IO,		/* [17] VDD IO */
		8'd31,	TT_PAD_OUT,			/* [16] uo[7] */
		8'd30,	TT_PAD_OUT,			/* [15] uo[6] */
		8'd29,	TT_PAD_OUT,			/* [14] uo[5] */
		8'd28,	TT_PAD_OUT,			/* [13] uo[4] */
		8'd27,	TT_PAD_OUT,			/* [12] uo[3] */
		8'd26,	TT_PAD_OUT,			/* [11] uo[2] */
		8'd25,	TT_PAD_OUT,			/* [10] uo[1] */
		8'd24,	TT_PAD_OUT,			/* [ 9] uo[0] */
		8'd0,	TT_PAD_GND_IO,		/* [ 8] GND IO */
		8'd0,	TT_PAD_NC,			/* [ 7] rsvd */
		8'd0,	TT_PAD_NC,			/* [ 6] rsvd */
		8'd0,	TT_PAD_NC,			/* [ 5] rsvd */
		8'd0,	TT_PAD_NC,			/* [ 4] rsvd */
		8'd0,	TT_PAD_NC,			/* [ 3] rsvd */
		8'd2,	TT_PAD_CTRL,		/* [ 2] ctrl_sel_rst_n */
		8'd1,	TT_PAD_CTRL,		/* [ 1] ctrl_sel_inc */
		8'd0,	TT_PAD_CTRL			/* [ 0] ctrl_ena */
	};

	genvar i;
	for (i=0; i<74; i=i+1)
	begin : gpio
		localparam [23:0] PAD_CFG = CONFIG[24*i+:24];

		tt_gf_gpio #(
			.CONFIG(PAD_CFG[15:0])
		) gpio_I (
			.k_zero  (k_zero),
			.k_one   (k_one),
			.pad_ana (pad_ana[PAD_CFG[23:16]]),
			.pad_in  (pad_in[PAD_CFG[23:16]]),
			.pad_out (pad_out[PAD_CFG[23:16]]),
			.pad_oe  (pad_oex[PAD_CFG[23:16]]),
			.pad_raw (pad_raw[i])
		);
	end


    // Chip ID
	// -------

    (* keep *)
    gf180mcu_ws_ip__id chip_id_I ();

    (* keep *)
    gf180mcu_ws_ip__logo logo_I ();

endmodule	// tt_gf_wrapper

(* blackbox *)
module gf180mcu_ws_ip__id;
endmodule

(* blackbox *)
module gf180mcu_ws_ip__logo;
endmodule
