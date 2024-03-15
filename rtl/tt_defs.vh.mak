/*
 * tt_defs.vh
 *
 * Shared defines
 *
 * Copyright (c) 2023 Sylvain Munaut <tnt@246tNt.com>
 * SPDX-License-Identifier: Apache-2.0
 */

`define TT_G_X  ${cfg.tt.grid.x}
`define TT_G_Y  ${cfg.tt.grid.y}

`define TT_N_AE ${cfg.tt.uio.ae}
`define TT_N_AU ${cfg.tt.uio.au}
`define TT_N_IO ${cfg.tt.uio.io}
`define TT_N_O  ${cfg.tt.uio.o}
`define TT_N_I  ${cfg.tt.uio.i}

<%
mux_mask = 0
if hasattr(cfg.tt, 'analog'):
	for grp in cfg.tt.analog:
		for mux_id in grp['mux_id']:
			mux_mask |= 1 << mux_id
%>
`define TT_MUX_MASK ${cfg.tt.grid.y}'h${'{:X}'.format(mux_mask)}
