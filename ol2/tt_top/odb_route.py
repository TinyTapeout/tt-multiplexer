#
# OpenDB script for custom IO routing for tt_top / user_project_wrapper
#
# Copyright (c) 2023 Sylvain Munaut <tnt@246tNt.com>
# SPDX-License-Identifier: Apache-2.0
#

import os
import sys

import odb

sys.path.append('../../py')
import tt
import tt_odb

import click
sys.path.insert(0, os.path.join(os.environ.get("OPENLANE_ROOT"), "scripts", "odbpy"))
from reader import click_odb


class Router:

	def __init__(self, reader, tti):
		# Save vars
		self.reader = reader
		self.tti    = tti

		# Find useful data
		tech = reader.db.getTech()

		self.layer_h = tech.findLayer('met3')
		self.layer_v = tech.findLayer('met4')
		self.via     = tech.findVia('M3M4_PR')

		self.x_spine = []
		self.y_muxes = {}

	def route_vspine_net(self, net):
		# Find extents as well as Y mux pos and X spine pos
		x_min   = None
		x_max   = None

		y_min   = None
		y_max   = None

		x_spine = None
		y_mux   = set()
		y_ctrl  = [None, None]

		for it in net.getITerms():
			# Get coordinates
			r, x, y = it.getAvgXY()
			if r is not True:
				continue

			# Collect the extent
			if (x_min is None) or (x < x_min):
				x_min = x

			if (x_max is None) or (x > x_max):
				x_max = x

			if (y_min is None) or (y < y_min):
				y_min = y

			if (y_max is None) or (y > y_max):
				y_max = y

			name = it.getInst().getName()
			if 'ctrl_I' in name:
				x_spine = x
				self.x_spine.append(x)
				y_ctrl = [ y - 1000, y + 1000 ]
			else:
				y_mux.add(y)
				self.y_muxes.setdefault(name, []).append(y)

		self.x_min = x_min
		self.x_max = x_max

		# Create wire and matching encoder
		new = False

		wire = net.getWire()

		if wire is None:
			wire = odb.dbWire.create(net)
			new = True

		encoder = odb.dbWireEncoder()
		encoder.begin(wire)

		# Create vertical spine
		# (split in 2 segments to help RCX be more correct)
		encoder.newPath(self.layer_v, 'FIXED')
		encoder.addPoint(x_spine, y_min)
		encoder.addPoint(x_spine, y_ctrl[0])

		encoder.newPath(self.layer_v, 'FIXED')
		encoder.addPoint(x_spine, y_ctrl[1])
		encoder.addPoint(x_spine, y_max)

		# Create horizontal link for each mux
		for y in y_mux:
			encoder.newPath(self.layer_h, 'FIXED')
			encoder.addPoint(x_min, y)
			encoder.addPoint(x_spine, y)
			encoder.addPoint(x_max, y)

			if new:
				continue

			encoder.newPath(self.layer_v, 'FIXED')
			encoder.addPoint(x_spine, y)
			encoder.addTechVia(self.via)

		encoder.end()

	def route_vspine(self):
		for i in range(self.tti.layout.vspine.iw):
			self.route_vspine_net(self.reader.block.findNet(f'top_I.spine_iw\\[{i:d}\\]'))
		for i in range(self.tti.layout.vspine.ow):
			self.route_vspine_net(self.reader.block.findNet(f'top_I.spine_ow\\[{i:d}\\]'))

	def create_spine_obs(self):
		# Find top/bottom
		y_min = min(sum(self.y_muxes.values(), []))
		y_max = max(sum(self.y_muxes.values(), []))

		# Create vspine obstruction
		x_min_spine = min(self.x_spine)
		x_max_spine = max(self.x_spine)

		odb.dbObstruction_create(self.reader.block,
			self.layer_v,
			x_min_spine, y_min,
			x_max_spine, y_max,
		)

		# Create horizontal link obstruction for each mux
		for k, v in self.y_muxes.items():
			y_min_hlink = min(v)
			y_max_hlink = max(v)

			odb.dbObstruction_create(self.reader.block,
				self.layer_h,
				self.x_min, y_min_hlink,
				self.x_max, y_max_hlink,
			)

	def create_macro_obs(self):
		# Get all layers
		tech = self.reader.db.getTech()

		layers = [
			tech.findLayer(ln)
				for ln in
					self.tti.cfg.pdk.tracks._cfg.keys()
		]

		# Iterate over all macros
		for inst in self.reader.instances:
			bb = inst.getBBox()
			for l in layers:
				odb.dbObstruction_create(self.reader.block,
					l,
					bb.xMin() + self.tti.layout.glb.margin.x.units,
					bb.yMin() + self.tti.layout.glb.margin.y.units,
					bb.xMax() - self.tti.layout.glb.margin.x.units,
					bb.yMax() - self.tti.layout.glb.margin.y.units,
				)


@click.command()
@click_odb
def route(
	reader,
):

	# Load TinyTapeout
	tti = tt.TinyTapeout(modules=False)

	# Create router
	r = Router(reader, tti)
	r.route_vspine()
	r.create_spine_obs()
	r.create_macro_obs()


if __name__ == "__main__":
	route()
