#
# OpenDB script for custom IO routing for tt_top / user_project_wrapper
#
# Copyright (c) 2023 Sylvain Munaut <tnt@246tNt.com>
# SPDX-License-Identifier: Apache-2.0
#

import os
import sys

import click
import odb

sys.path.append('../../py')
import tt

try:
	from reader import click_odb
	interactive = False
except:
	sys.path.insert(0, os.path.join("/mnt/pdk/OL2/openlane2.ihp/openlane", "scripts", "odbpy"))
	interactive = True
	from reader import click_odb


@click.command()
@click_odb
def route_analog_pins(
	reader,
):
	tti = tt.TinyTapeout()

	# Manual routing for analog pins
	tech = reader.db.getTech()
	metal5 = tech.findLayer("Metal5")
	via4 = tech.findVia("Via4_YX_so")
	via3 = tech.findVia("Via3_XY_so")

	analog_track = odb.dbTechNonDefaultRule_create(reader.block, 'analog_track')
	for layer in ['Metal1', 'Metal2', 'Metal3', 'Metal4', 'Metal5', 'TopMetal1']:
		layer_rule = odb.dbTechLayerRule_create(analog_track, tech.findLayer(layer))
		layer_rule.setWidth(900)
		layer_rule.setSpacing(2700)

	for inst in reader.block.getInsts():
		name = inst.getMaster().getName()
		if not name.startswith("tt_um_"):
			continue
		user_module = next(filter(lambda m: m.name == name[6:], tti.placer.modules), None)
		if not user_module.analog_dedicated:
			continue
		paths = user_module.analog_dedicated["paths"]
		for term in inst.getITerms():
			net = term.getNet()
			if net.getName() in paths:
				net.clearSpecial()
				net.setNonDefaultRule(analog_track)
				bbox = term.getBBox()
				wire = odb.dbWire.create(net)
				encoder = odb.dbWireEncoder()
				encoder.begin(wire)
				encoder.newPath(metal5, "FIXED", analog_track.getLayerRule(metal5))
				x = bbox.xMin()
				y = bbox.yCenter()
				encoder.addPoint(x, y)
				for item in paths[net.getName()]:
					if "x" in item:
						x = item["x"]
						encoder.addPoint(x, y)
					if "y" in item:
						y = item["y"]
						encoder.addPoint(x, y)
					if "via" in item:
						encoder.addTechVia(tech.findVia(item["via"]))
				encoder.end()


if __name__ == "__main__":
	route_analog_pins()
