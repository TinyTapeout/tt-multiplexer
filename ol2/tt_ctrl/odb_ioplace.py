#
# OpenDB script for custom IO placement for tt_ctrl
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
	layer_ns = reader.tech.findLayer("met4")
	layer_we = reader.tech.findLayer("met3")

	# Vertical spine
	for pn, pp in tti.layout.ply_ctrl_vspine.items():
		tt_odb.place_pin(die_area, layer_ns, bterm_map.pop(pn.replace('spine','spine_top')), pp, 'N')
		tt_odb.place_pin(die_area, layer_ns, bterm_map.pop(pn.replace('spine','spine_bot')), pp, 'S')

	# IO Top
	for pn, pp in tti.layout.ply_ctrl_io_top.items():
		tt_odb.place_pin(die_area, layer_ns, bterm_map.pop(pn), pp, 'N')

	# IO Bottom
	for pn, pp in tti.layout.ply_ctrl_io_bot.items():
		tt_odb.place_pin(die_area, layer_ns, bterm_map.pop(pn), pp, 'S')


if __name__ == "__main__":
	io_place()
