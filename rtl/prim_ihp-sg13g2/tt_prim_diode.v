/*
 * tt_prim_diode.v
 *
 * TT Primitive
 * Antenna diode
 *
 * Copyright (c) 2024 Sylvain Munaut <tnt@246tNt.com>
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_prim_diode (
	inout  wire diode
);

	(* keep *)
	sg13g2_antennanp cell0_I (
		.A (diode)
	);

endmodule // tt_prim_diode
