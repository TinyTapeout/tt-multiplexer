/*
 * tt_ckt_ana.v
 *
 * Blackbox for the analog IO contact
 *
 * Copyright (c) 2026 Sylvain Munaut <tnt@246tNt.com>
 * SPDX-License-Identifier: Apache-2.0
 */

(* blackbox *)
module tt_ckt_ana (
    inout wire ASIG5V,
    inout wire analog
);

	assign ASIG5V = analog;
	assign analog = ASIG5V;

endmodule
