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

from openlane.common.misc import get_openlane_root
sys.path.insert(0, os.path.join(get_openlane_root(), "scripts", "odbpy"))
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
		encoder.newPath(self.layer_v, 'FIXED')
		encoder.addPoint(x_spine, y_min)
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
		# Find controller
		ctrl_inst = self.reader.block.findInst('top_I.ctrl_I')

		# Route each spine net
		for i in range(self.tti.layout.vspine.iw):
			self.route_vspine_net(ctrl_inst.findITerm(f'spine_bot_iw[{i:d}]').getNet())
			self.route_vspine_net(ctrl_inst.findITerm(f'spine_top_iw[{i:d}]').getNet())

		for i in range(self.tti.layout.vspine.ow):
			self.route_vspine_net(ctrl_inst.findITerm(f'spine_bot_ow[{i:d}]').getNet())
			self.route_vspine_net(ctrl_inst.findITerm(f'spine_top_ow[{i:d}]').getNet())

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

	def route_um_tieoffs(self):
		# Get track info
		# We route horizontally on met4, non-preferred direction ...
		track_cfg = self.tti.cfg.pdk.tracks.met4.y

		def track_align(v):
			return track_cfg.offset + ((v - track_cfg.offset) // track_cfg.pitch) * track_cfg.pitch

		# Scan all the muxes
		for inst in self.reader.instances:
			# Not a mux -> skip
			if inst.getMaster().getName() != 'tt_mux':
				continue

			# Instance bounding box
			inst_bbox = inst.getBBox()
			inst_y_mid = ( inst_bbox.yMin() + inst_bbox.yMax() ) // 2

			# Scan all um_k_zero[]
			for k0_it in inst.getITerms():
				# Not right port ?
				if not k0_it.getMTerm().getName().startswith('um_k_zero'):
					continue

				# Get net and check if there are anything to tie
				k0_net = k0_it.getNet()
				if k0_net.getITermCount() <= 1:
					continue

				# Get layer
				layer = k0_it.getMTerm().getMPins()[0].getGeometry()[0].getTechLayer()

				# Get strap Y position
				sy = k0_it.getAvgXY()[2]

				if sy > inst_y_mid:
					sy = track_align(inst_bbox.yMax() + track_cfg.pitch - 1)
				else:
					sy = track_align(inst_bbox.yMin())

					# FIXME: Workaround OpenROAD#3753
				if sy > inst_y_mid:
					sy = inst_bbox.yMax() + track_cfg.width // 2
				else:
					sy = inst_bbox.yMin() - track_cfg.width // 2

				# Start custom routing
				wire = odb.dbWire.create(k0_net)

				encoder = odb.dbWireEncoder()
				encoder.begin(wire)

				# Collect all ITerms positions
				it_pos = [ it.getAvgXY()[1:] for it in k0_net.getITerms() ]
				it_pos.sort()

				encoder.newPath(layer, 'FIXED')

				for n, (px, py) in enumerate(it_pos):
					break	# FIXME: Workaround OpenROAD #3753
					if n == 0:
						encoder.addPoint(px, py)
						encoder.addPoint(px, sy)
						continue
					elif n > 1:
						encoder.newPath(j)
					j = encoder.addPoint(px, sy)
					encoder.addPoint(px, py)

					# FIXME: Workaround OpenROAD #3753
				encoder.addPoint(it_pos[ 0][0], sy)
				encoder.addPoint(it_pos[-1][0], sy)

				# End routing
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

		# Prepare recording of used tracks
		self.k01_x_left  = []
		self.k01_x_right = []
		self.k01_y_bot   = []
		self.k01_y_top   = []

		# Deal with each constant
		for idx, port_name in enumerate(['k_zero', 'k_one']):
			# ITerm on controller
			ctrl_iterm = ctrl_inst.findITerm(port_name)
			r, x, y = ctrl_iterm.getAvgXY()
			if r is not True:
				continue

			# Set the margin
			margin = 0

			# Limits
			cfg_tv = self.tti.cfg.pdk.tracks.met4.x
			cfg_th = self.tti.cfg.pdk.tracks.met3.y

			def a(cfg, v):
				return cfg.offset + ((v - cfg.offset) // cfg.pitch) * cfg.pitch

			lx = [
				cfg_tv.offset + cfg_tv.pitch * (idx + margin),
				a(cfg_tv, die.xMax() - cfg_tv.pitch * (idx + margin))
			]

			ly = [
				cfg_th.offset + cfg_th.pitch * (idx + margin),
				a(cfg_th, die.yMax() - cfg_th.pitch * (idx + margin))
			]

			# Record the tracks we used so we can create obstructions
			self.k01_x_left.append  (lx[0])
			self.k01_x_right.append (lx[1])
			self.k01_y_bot.append   (ly[0])
			self.k01_y_top.append   (ly[1])

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
		lx_left = [
			min(self.k01_x_left) - cfg_v.pitch // 2,
			max(self.k01_x_left) + cfg_v.pitch // 2,
		]

		lx_right = [
			min(self.k01_x_right) - cfg_v.pitch // 2,
			max(self.k01_x_right) + cfg_v.pitch // 2,
		]

		ly_bot = [
			min(self.k01_y_bot) - cfg_h.pitch // 2,
			max(self.k01_y_bot) + cfg_h.pitch // 2,
		]

		ly_top = [
			min(self.k01_y_top) - cfg_h.pitch // 2,
			max(self.k01_y_top) + cfg_h.pitch // 2,
		]

		# Left
		odb.dbObstruction_create(self.reader.block,
			layer_v, lx_left[0], ly_bot[0], lx_left[1], ly_top[1])

		# Right
		odb.dbObstruction_create(self.reader.block,
			layer_v, lx_right[0], ly_bot[0], lx_right[1], ly_top[1])

		# Bottom
		odb.dbObstruction_create(self.reader.block,
			layer_h, lx_left[0], ly_bot[0], lx_right[1], ly_bot[1])

		# Top
		odb.dbObstruction_create(self.reader.block,
			layer_h, lx_left[0], ly_top[0], lx_right[1], ly_top[1])



class PowerStrapper:

	def __init__(self, reader, tti):
		# Save vars
		self.reader = reader
		self.tti    = tti

		# Find useful data
		tech = reader.db.getTech()

		self.layer = tech.findLayer('met5')
		self.via   = tech.findVia('M3M4_PR')

	def _find_via(self, inst, port_name):
		# Helper to check if point is within a bounding box
		def in_bbox(bbox, pt):
			return (
				(bbox.xMin() <= pt[0] <= bbox.xMax()) and
				(bbox.yMin() <= pt[1] <= bbox.yMax())
			)

		# Block bounding box
		bbox = inst.getBBox()

		# Scan all geometry from special VGND wire
		for x in inst.findITerm(port_name).getNet().getSWires()[0].getWires():
			if  x.isVia() and in_bbox(bbox, x.getViaXY()):
				return x.getBlockVia()

		return None

	def _get_y_pos(self, pg_inst):
		# Is it single or double height ?
		h = int(pg_inst.getMaster().getName()[-1])

		# Get switch physical dimensions
		bbox = pg_inst.getBBox()

		y_min = bbox.yMin()
		y_max = bbox.yMax()

		# Split depending if we want 1 or 3 straps
		if h == 1:
			return [ (y_min + y_max) // 2 ]

		elif h == 2:
			step = (y_max - y_min) // 4
			return [
				y_min + step,
				(y_min + y_max) // 2,
				y_max - step,
			]

		else:
			raise RuntimeError('Unsupported heigh Power Switch')

	def _get_x_data(self, pg_inst, blk_inst):
		# Get terminals
		it_pg  = pg_inst.findITerm('GPWR')
		it_blk = blk_inst.findITerm('VPWR')

		# Find geometry for thos terminals
		geom_pg  = it_pg.getGeometries()
		geom_blk = it_blk.getGeometries()
		geom = geom_pg + geom_blk

		# Extent
		xl = min([x.xMin() for x in geom])
		xr = max([x.xMax() for x in geom])

		# Center positions
		xp = [(x.xMin() + x.xMax()) // 2 for x in geom]

		# Via type index
		xv = [ 0 ] * len(geom_pg) + [ 1 ] * len(geom_blk)

		# Return result
		return xl, xr, xp, xv

	def _draw_stripe(self, sw, vias, y, xl, xr, xp, xv):
		# Stripe
		odb.createSBoxes(sw, self.layer, [odb.Rect(xl, y-7000, xr, y+7000)], "STRIPE")

		# Dual vias
		for x, i in zip(xp, xv):
			odb.createSBoxes(sw, vias[i], [odb.Point(x, y-3500), odb.Point(x, y+3500)], "STRIPE")

	def run(self):
		# Find all power switch instances
		for pg_inst in self.reader.block.getInsts():
			# Is it a power switch ?
			if not pg_inst.getName().endswith('tt_pg_vdd_I'):
				continue

			# Get the matching block
			blk_name = '.'.join(pg_inst.getName().split('.')[:-1] + ['tt_um_I'])
			blk_inst = self.reader.block.findInst(blk_name)

			# Find the vias types
			via_pg  = self._find_via(pg_inst,  'VPWR')
			via_blk = self._find_via(blk_inst, 'VGND')

			# Select the y positions
			yp = self._get_y_pos(pg_inst)

			# Get the X data (extent + via pos)
			xl, xr, xp, xv = self._get_x_data(pg_inst, blk_inst)

			# Find net and create the matching special wire
			net = blk_inst.findITerm('VPWR').getNet()
			sw = odb.dbSWire.create(net, "ROUTED")

			# Draw for each y position
			for y in yp:
				self._draw_stripe(sw, [ via_pg, via_blk ], y, xl, xr, xp, xv)


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
	r.route_um_tieoffs()

	# Create the power strapper
	p = PowerStrapper(reader, tti)
	p.run()


if __name__ == "__main__":
	route()
