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
	via4 = tech.findVia("Via4_YX_so")
	via3 = tech.findVia("Via3_XY_so")
	for inst in reader.block.getInsts():
		if inst.getMaster().getName() == "tt_um_htfab_r2r_dac":
			for term in inst.getITerms():
				net = term.getNet()
				if net.getName() == "pad_raw[58]":
					net.clearSpecial()
					bbox = term.getBBox()
					wire = odb.dbWire.create(net)
					encoder = odb.dbWireEncoder()
					encoder.begin(wire)
					encoder.newPath(tech.findLayer("Metal5"), "FIXED")
					encoder.addPoint(bbox.xMin(), bbox.yCenter())
					encoder.addPoint(bbox.xMin() - 50000, bbox.yCenter())
					encoder.addTechVia(via4)
					encoder.addPoint(bbox.xMin() - 50000, 988490)
					encoder.addPoint(319855, 988490)
					encoder.addTechVia(via3)
					encoder.addPoint(319855, 987490)
					encoder.end()


if __name__ == "__main__":
	route_analog_pins()
