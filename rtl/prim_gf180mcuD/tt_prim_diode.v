/*
 * tt_prim_diode.v
 *
 * TT Primitive
 * Antenna diode
 *
 * Copyright (c) 2025 Sylvain Munaut <tnt@246tNt.com>
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_prim_diode (
	inout  wire diode
);

`ifdef WITH_POWER
	wire VPWR = 1'b1;
	wire VGND = 1'b0;
`endif

			(* keep *)
			gf180mcu_fd_sc_mcu7t5v0__antenna cell0_I (
`ifdef WITH_POWER
				.VDD (VPWR),
				.VSS (VGND),
				.VPW (VGND),
				.VNW (VPWR),
`endif
				.I (diode)
			);

endmodule // tt_prim_diode
