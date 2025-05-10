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
		if inst.getMaster().getName() == "tt_um_htfab_r2r_dac":
			for term in inst.getITerms():
				net = term.getNet()
				if net.getName() == "pad_raw[58]":
					net.clearSpecial()
					net.setNonDefaultRule(analog_track)
					bbox = term.getBBox()
					wire = odb.dbWire.create(net)
					encoder = odb.dbWireEncoder()
					encoder.begin(wire)
					encoder.newPath(metal5, "FIXED", analog_track.getLayerRule(metal5))
					encoder.addPoint(bbox.xMin(), bbox.yCenter())
					encoder.addPoint(bbox.xMin() - 50000, bbox.yCenter())
					encoder.addTechVia(via4)
					encoder.addPoint(bbox.xMin() - 50000, 988490)
					encoder.addPoint(319855, 988490)
					encoder.addTechVia(via3)
					encoder.addPoint(319855, 987490)
					encoder.end()
		if inst.getMaster().getName() == "tt_um_algofoogle_antonalog":
			for term in inst.getITerms():
				net = term.getNet()
				if net.getName() == "pad_raw[59]":
					net.clearSpecial()
					net.setNonDefaultRule(analog_track)
					bbox = term.getBBox()
					wire = odb.dbWire.create(net)
					encoder = odb.dbWireEncoder()
					encoder.begin(wire)	
					encoder.newPath(metal5, "FIXED", analog_track.getLayerRule(metal5))
					encoder.addPoint(bbox.xMin(), bbox.yCenter())
					encoder.addPoint(bbox.xMin() - 47300, bbox.yCenter())
					encoder.addTechVia(via4)
					encoder.addPoint(bbox.xMin() - 47300, 886490)
					encoder.addPoint(319855, 886490)
					encoder.addTechVia(via3)
					encoder.addPoint(319855, 884490)
					encoder.end()
				if net.getName() == "pad_raw[60]":
					net.clearSpecial()
					net.setNonDefaultRule(analog_track)
					bbox = term.getBBox()
					wire = odb.dbWire.create(net)
					encoder = odb.dbWireEncoder()
					encoder.begin(wire)
					encoder.newPath(metal5, "FIXED", analog_track.getLayerRule(metal5))
					encoder.addPoint(bbox.xMin(), bbox.yCenter())
					encoder.addPoint(bbox.xMin() - 50000, bbox.yCenter())
					encoder.addTechVia(via4)
					encoder.addPoint(bbox.xMin() - 50000, 784490)
					encoder.addPoint(319855, 784490)
					encoder.addTechVia(via3)
					encoder.addPoint(319855, 782490)
					encoder.end()
				if net.getName() == "pad_raw[61]":
					net.clearSpecial()
					net.setNonDefaultRule(analog_track)
					bbox = term.getBBox()
					wire = odb.dbWire.create(net)
					encoder = odb.dbWireEncoder()
					encoder.begin(wire)
					encoder.newPath(metal5, "FIXED", analog_track.getLayerRule(metal5))
					encoder.addPoint(bbox.xMin(), bbox.yCenter())
					encoder.addPoint(bbox.xMin() - 50000, bbox.yCenter())
					encoder.addTechVia(via4)
					encoder.addPoint(bbox.xMin() - 50000, 682490)
					encoder.addPoint(319855, 682490)
					encoder.addTechVia(via3)
					encoder.addPoint(319855, 680490)
					encoder.end()


if __name__ == "__main__":
	route_analog_pins()
