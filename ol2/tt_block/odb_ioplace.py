#
# OpenDB script for custom IO placement for the TT user blocks
#
# Copyright (c) 2023 Sylvain Munaut <tnt@246tNt.com>
# SPDX-License-Identifier: Apache-2.0
#

import os
import sys

sys.path.append('../../py')
import tt
import tt_odb

import click

from reader import click_odb


@click.command()
@click_odb
def io_place(
	reader,
):

	# Load TinyTapeout
	tti = tt.TinyTapeout(modules=False)

	# Terminal name mapping
	bterm_map = {b.getName(): b for b in reader.block.getBTerms()}

	# Find die & layers
	die_area = reader.block.getDieArea()
	layer_ns = reader.tech.findLayer(tti.cfg.tt.spine.vlayer)

	# Adjust pin position (in case there is a power gate)
	pin_ofs = die_area.xMax() - die_area.xMin()
	pin_ofs -= tti.layout.glb.block.width
	while pin_ofs > 0:
		pin_ofs -= tti.layout.glb.block.pitch

	# User block to mux
	for pn, pp in tti.layout.ply_block.items():
		tt_odb.place_pin(die_area, layer_ns, bterm_map.pop(pn), pp + pin_ofs, 'N')

	# User block analog (optional pins !)
	for pn, pp in tti.layout.ply_block_analog.items():
		if pn not in bterm_map:
			continue
		tt_odb.place_pin(die_area, layer_ns, bterm_map.pop(pn), pp + pin_ofs, 'S', wide=True)


if __name__ == "__main__":
	io_place()
