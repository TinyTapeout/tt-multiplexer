/*
 * tt_prim_diode.v
 *
 * TT Primitive
 * Antenna diode
 *
 * Author: Sylvain Munaut <tnt@246tNt.com>
 */

`default_nettype none

module tt_prim_diode (
	inout  wire diode
);

			sky130_fd_sc_hd__diode_2 cell0_I (
`ifdef WITH_POWER
				.VPWR (1'b1),
				.VGND (1'b0),
`endif
				.DIODE (diode),
			)

endmodule // tt_prim_diode
