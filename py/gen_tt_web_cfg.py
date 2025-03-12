#!/usr/bin/env python3

#
# Outputs config file for the web visualization
#
# Copyright (c) 2024 Sylvain Munaut <tnt@246tNt.com>
# SPDX-License-Identifier: Apache-2.0
#

import json
import sys

import tt


def main(argv0):
	tti = tt.TinyTapeout(modules=False)
	tti.layout

	web_cfg = {
		'rowCount'        : tti.cfg.tt.grid.y // 2,
		'colCount'        : tti.cfg.tt.grid.x,
		'dieWidth'        : tti.cfg.pdk.die.width       / 1000,
		'dieHeight'       : tti.cfg.pdk.die.height      / 1000,
		'xPad'            : tti.layout.glb.top.pos_x    / 1000,
		'topPad'          : (tti.cfg.pdk.die.height - tti.layout.glb.top.pos_y - tti.layout.glb.top.height) / 1000,
		'bottomPad'       : tti.layout.glb.top.pos_y    / 1000,
		'spineWidth'      : (tti.layout.glb.ctrl.width + 2 * tti.layout.glb.margin.x) / 1000,
		'muxWidth'        : tti.layout.glb.mux.width    / 1000,
		'muxHeight'       : tti.layout.glb.mux.height   / 1000,
		'ctrlWidth'       : tti.layout.glb.ctrl.width   / 1000,
		'ctrlHeight'      : tti.layout.glb.ctrl.height  / 1000,
		'colDistance'     : tti.layout.glb.block.pitch  / 1000,
		'rowDistance'     : tti.layout.glb.branch.pitch / 1000,
		'powerGateWidth'  : (tti.layout.glb.pg_vdd.width + tti.layout.glb.margin.x) / 1000,
		'tileHeight'      : tti.layout.glb.block.height / 1000,
		'verticalSpacing' : tti.layout.glb.margin.y     / 1000,
	}

	print(json.dumps(web_cfg, indent=4))


if __name__ == '__main__':
	main(*sys.argv)
