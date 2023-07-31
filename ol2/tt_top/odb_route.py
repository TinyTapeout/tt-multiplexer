#
# OpenDB script for custom IO routing for tt_top / user_project_wrapper
#
# Copyright (c) 2023 Sylvain Munaut <tnt@246tNt.com>
# SPDX-License-Identifier: Apache-2.0
#

import os
import sys
import yaml

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
		wire = odb.dbWire.create(net)

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
					bb.xMin() + self.tti.layout.glb.margin.x,
					bb.yMin() + self.tti.layout.glb.margin.y,
					bb.xMax() - self.tti.layout.glb.margin.x,
					bb.yMax() - self.tti.layout.glb.margin.y,
				)

	def route_pad(self):
		# Vias
		tech = self.reader.db.getTech()

		via_m23 = tech.findVia('M2M3_PR')
		via_m34 = tech.findVia('M3M4_PR')

		# Find controller instance
		ctrl_inst = self.reader.block.findInst('top_I.ctrl_I')

		# Load data file
		data = yaml.load(open('route_data.yaml'), yaml.FullLoader)['ports']

		# Iterate through data file
		for port_name, rpts in data.items():
			# Starting point
			it = ctrl_inst.findITerm(port_name)
			sx, sy = it.getAvgXY()[1:]

			# Net / Wire
			net = it.getNet()
			wire = odb.dbWire.create(net)

			# Ending point
			bt = net.get1stBTerm()
			ex, ey = bt.getFirstPinLocation()[1:]
			el = bt.getBPins()[0].getBoxes()[0].getTechLayer()

			# Set via type for intermediate routing points
			rpts = [(v, via_m34) for v in rpts]

			# Append ending point to intermediate routing points
			if len(rpts) & 1:
				rpts.extend([(ex, via_m23), (ey, None)])
			else:
				rpts.extend([(ey, via_m34), (ex, None)])

			# Encoder start
			encoder = odb.dbWireEncoder()
			encoder.begin(wire)

			encoder.newPath(self.layer_v, 'FIXED')
			encoder.addPoint(sx, sy)

			# Scan through routing points
			px = sx
			py = sy
			xy = True

			for pt, vt in rpts:
				# Next point
				if xy:
					py = pt
				else:
					px = pt

				encoder.addPoint(px, py)

				# Toggle routing direction
				xy ^= True

				# Add via
				if vt is not None:
					encoder.addTechVia(vt)

			# Encoder end
			encoder.end()

	def route_k01(self):
		# Vias
		tech = self.reader.db.getTech()

		via = {
			('met2', 'met3'): tech.findVia('M2M3_PR'),
			('met3', 'met4'): tech.findVia('M3M4_PR'),
		}

		# Get full die area
		die = self.reader.block.getDieArea()

		# Find controller instance
		ctrl_inst = self.reader.block.findInst('top_I.ctrl_I')

		# Deal with each constant
		for idx, port_name in enumerate(['k_zero', 'k_one']):
			# ITerm on controller
			ctrl_iterm = ctrl_inst.findITerm(port_name)
			r, x, y = ctrl_iterm.getAvgXY()
			if r is not True:
				continue

			# Limits
			cfg_tv = self.tti.cfg.pdk.tracks.met4.x
			cfg_th = self.tti.cfg.pdk.tracks.met3.y

			def a(cfg, v):
				return cfg.offset + ((v - cfg.offset) // cfg.pitch) * cfg.pitch

			lx = [
				cfg_tv.offset + cfg_tv.pitch * idx,
				a(cfg_tv, die.xMax() - cfg_tv.pitch * idx)
			]

			ly = [
				cfg_th.offset + cfg_th.pitch * idx,
				a(cfg_th, die.yMax() - cfg_th.pitch * idx)
			]

			# Net / Wire
			net = ctrl_iterm.getNet()
			wire = odb.dbWire.create(net)

			# Encoder start
			encoder = odb.dbWireEncoder()
			encoder.begin(wire)

			# Line toward bottom
			encoder.newPath(self.layer_v, 'FIXED')
			encoder.addPoint(x, y)
			encoder.addPoint(x, ly[0])
			encoder.addTechVia(self.via)
			encoder.addPoint(lx[1], ly[0])
			encoder.addTechVia(self.via)
			encoder.addPoint(lx[1], ly[1])
			encoder.addTechVia(self.via)
			encoder.addPoint(lx[0], ly[1])
			encoder.addTechVia(self.via)
			encoder.addPoint(lx[0], ly[0])
			encoder.addTechVia(self.via)
			encoder.addPoint(x, ly[0])

			# Iterate over all BTerms
			for pad_bterm in net.getBTerms():
				# Get pin location / Bounding Box
				pr, px, py = pad_bterm.getFirstPinLocation()
				if pr is not True:
					continue

				pad_bb  = pad_bterm.getBBox()
				pad_box = pad_bterm.getBPins()[0].getBoxes()[0]
				pad_ly  = pad_box.getTechLayer()

				# Start path
				encoder.newPath(pad_ly, 'FIXED')
				encoder.addPoint(px, py)

				# Check side
				if pad_bb.yMin() < 0:				# Bottom
					encoder.addPoint(px, ly[0])
					encoder.addTechVia(via[(pad_ly.getName(), self.layer_h.getName())])

				elif pad_bb.yMax() > die.yMax():	# Top
					encoder.addPoint(px, ly[1])
					encoder.addTechVia(via[(pad_ly.getName(), self.layer_h.getName())])

				elif pad_bb.xMin() < 0:				# Left
					encoder.addPoint(lx[0], py)
					encoder.addTechVia(via[(pad_ly.getName(), self.layer_v.getName())])

				elif pad_bb.xMax() > die.xMax():	# Right
					encoder.addPoint(lx[1], py)
					encoder.addTechVia(via[(pad_ly.getName(), self.layer_v.getName())])

				else:
					# ?!?!?
					continue

			# Encoder end
			encoder.end()

	def create_k01_obs(self):

		# Get all layers and config
		tech = self.reader.db.getTech()

		layer_v = tech.findLayer('met4')
		layer_h = tech.findLayer('met3')

		cfg_v = self.tti.cfg.pdk.tracks.met4.x
		cfg_h = self.tti.cfg.pdk.tracks.met3.y

		die = self.reader.block.getDieArea()

		# Limits
		def a(cfg, v):
			return cfg.offset + ((v - cfg.offset) // cfg.pitch) * cfg.pitch

		lx = [
			cfg_v.offset + cfg_v.pitch,
			a(cfg_v, die.xMax() - cfg_v.pitch)
		]

		ly = [
			cfg_h.offset + cfg_h.pitch,
			a(cfg_h, die.yMax() - cfg_h.pitch)
		]

		# Left
		odb.dbObstruction_create(self.reader.block,
			layer_v, 0, 0, lx[0], die.yMax())

		# Right
		odb.dbObstruction_create(self.reader.block,
			layer_v, lx[1], 0, die.xMax(), die.yMax())

		# Bottom
		odb.dbObstruction_create(self.reader.block,
			layer_h, 0, 0, die.xMax(), ly[0])

		# Top
		odb.dbObstruction_create(self.reader.block,
			layer_h, 0, ly[1], die.xMax(), die.yMax())


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
	r.route_k01()
	r.create_k01_obs()
	r.route_pad()


if __name__ == "__main__":
	route()
