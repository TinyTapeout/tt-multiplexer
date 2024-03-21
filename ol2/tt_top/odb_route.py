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
		y_mux   = dict()
		y_ctrl  = [None, None]

		for it in net.getITerms():
			# Get coordinates
			r, x, y = it.getAvgXY()
			if r is not True:
				continue

			# Collect the extent
			if (y_min is None) or (y < y_min):
				y_min = y

			if (y_max is None) or (y > y_max):
				y_max = y

			name = it.getInst().getName()
			if 'ctrl_I' in name:
				x_spine = x
				self.x_spine.append(x)
			else:
				y_mux.setdefault(y, []).append(x)
				self.y_muxes.setdefault(name, (x, []))[1].append(y)

		# Create wire and matching encoder
		wire = odb.dbWire.create(net)

		encoder = odb.dbWireEncoder()
		encoder.begin(wire)

		# Create vertical spine
		encoder.newPath(self.layer_v, 'FIXED')
		encoder.addPoint(x_spine, y_min)
		encoder.addPoint(x_spine, y_max)

		# Create horizontal link for each mux
		for y,xl in y_mux.items():
			xl.append(x_spine)
			x_min_l = min(xl)
			x_max_l = max(xl)

			encoder.newPath(self.layer_h, 'FIXED')
			if x_min_l < x_spine:
				encoder.addPoint(x_min_l, y)
			encoder.addPoint(x_spine, y)
			if x_max_l > x_spine:
				encoder.addPoint(x_max_l, y)

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
		y_min = min(sum([yl for xl,yl in self.y_muxes.values()], []))
		y_max = max(sum([yl for xl,yl in self.y_muxes.values()], []))

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
			x_min_hlink = min([v[0], x_min_spine])
			x_max_hlink = max([v[0], x_max_spine])
			y_min_hlink = min(v[1])
			y_max_hlink = max(v[1])

			odb.dbObstruction_create(self.reader.block,
				self.layer_h,
				x_min_hlink, y_min_hlink,
				x_max_hlink, y_max_hlink,
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

	def k01_get_track(self, side, idx):
		# Get full die area
		die = self.reader.block.getDieArea()

		# Prepare recording of used tracks if not done already
		if not hasattr(self, 'k01_tracks'):
			self.k01_tracks = {
				'left':  [],
				'right': [],
				'bot':   [],
				'top':   [],
			}

		# Track config
		cfg_tv = self.tti.cfg.pdk.tracks.met4.x
		cfg_th = self.tti.cfg.pdk.tracks.met3.y

		# Alignement function
		def a(cfg, v):
			return cfg.offset + ((v - cfg.offset) // cfg.pitch) * cfg.pitch

		# Return requested track
		if side == 'left':
			t = cfg_tv.offset + cfg_tv.pitch * idx

		elif side == 'right':
			t = a(cfg_tv, die.xMax() - cfg_tv.pitch * idx)

		elif side == 'bot':
			t = cfg_th.offset + cfg_th.pitch * idx

		elif side == 'top':
			t = a(cfg_th, die.yMax() - cfg_th.pitch * idx)

		else:
			# ?!!?
			t = None

		self.k01_tracks[side].append(t)
		return t;

	def route_k01_gpio(self):
		# Get full die area
		die = self.reader.block.getDieArea()

		# Vias
		tech = self.reader.db.getTech()

		via = {
			('met2', 'met3'): tech.findVia('M2M3_PR'),
			('met3', 'met4'): tech.findVia('M3M4_PR'),
		}

		# Scan all BTerm to find gpio_loopback_{zero,one}[]
		for bterm in self.reader.block.getBTerms():
			# Check it's a bterm of interest
			if not bterm.getName().startswith('gpio_loopback'):
				continue

			# Select index
			if 'zero' in bterm.getName():
				idx = 0
			elif 'one' in bterm.getName():
				idx = 1

			# Select side
			bt_bbox = bterm.getBBox()
			if   bt_bbox.xMin() < die.xMin():
				side = 'left'
			elif bt_bbox.xMax() > die.xMax():
				side = 'right'
			elif bt_bbox.yMin() < die.yMin():
				side = 'bot'
			elif bt_bbox.yMax() > die.yMax():
				side = 'top'

			# Get track
			trk = self.k01_get_track(side, idx)

			# Get layer of bterm
			bterm_box = bterm.getBPins()[0].getBoxes()[0]
			bterm_ly  = bterm_box.getTechLayer()

			# Get the coordinates for all other bterms on net
			net = bterm.getNet()

			pos = []

			for bterm_sec in net.getBTerms():
				# Check it's in the same layer
				if bterm_sec.getBPins()[0].getBoxes()[0].getTechLayer().getName() != bterm_ly.getName():
					continue

				# Get position
				pr, px, py = bterm_sec.getFirstPinLocation()
				if pr is not True:
					continue

				# Record it
				pos.append( (px, py) )

			# Create new wire
			wire = odb.dbWire.create(net)

			# Encoder start
			encoder = odb.dbWireEncoder()
			encoder.begin(wire)

			# Draw
			if side in ['left', 'right']:
				# Vertical segment
				encoder.newPath(self.layer_v, 'FIXED')
				encoder.addPoint(trk, min([p[1] for p in pos]))
				encoder.addPoint(trk, max([p[1] for p in pos]))

				# Connect each position
				for px, py in pos:
					encoder.newPath(bterm_ly, 'FIXED')
					encoder.addPoint(px, py)
					encoder.addPoint(trk, py)
					encoder.addTechVia(via[(bterm_ly.getName(), self.layer_v.getName())])

			elif side in ['bot', 'top']:
				# Horizontal segment
				encoder.newPath(self.layer_h, 'FIXED')
				encoder.addPoint(min([p[0] for p in pos]), trk)
				encoder.addPoint(max([p[0] for p in pos]), trk)

				# Connect each position
				for px, py in pos:
					encoder.newPath(bterm_ly, 'FIXED')
					encoder.addPoint(px, py)
					encoder.addPoint(px, trk)
					encoder.addTechVia(via[(bterm_ly.getName(), self.layer_h.getName())])

			# Encoder end
			encoder.end()

	def route_k01_global(self):
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

		# Start index
		idx = 2

		# Deal with each constant
		for port_name in ['k_zero', 'k_one']:
			# ITerm on controller
			ctrl_iterm = ctrl_inst.findITerm(port_name)
			r, x, y = ctrl_iterm.getAvgXY()
			if r is not True:
				continue

			# Get associated net
			net = ctrl_iterm.getNet()

			# Check if there are any users
			if (net is None) or (len(net.getBTerms()) == 0):
				continue

			# Limits
			lx = [
				self.k01_get_track('left', idx),
				self.k01_get_track('right', idx),
			]

			ly = [
				self.k01_get_track('bot', idx),
				self.k01_get_track('top', idx),
			]

			idx += 1

			# Create new wire
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

		# No tracks ?
		if not hasattr(self, 'k01_tracks'):
			return

		# Get all layers and config
		tech = self.reader.db.getTech()

		layer_v = tech.findLayer('met4')
		layer_h = tech.findLayer('met3')

		cfg_v = self.tti.cfg.pdk.tracks.met4.x
		cfg_h = self.tti.cfg.pdk.tracks.met3.y

		die = self.reader.block.getDieArea()

		# Limits
		if self.k01_tracks['left']:
			lx_left = [
				min(self.k01_tracks['left']) - cfg_v.pitch // 2,
				max(self.k01_tracks['left']) + cfg_v.pitch // 2,
			]
		else:
			lx_left = [ die.xMin(), die.xMin() ]

		if self.k01_tracks['right']:
			lx_right = [
				min(self.k01_tracks['right']) - cfg_v.pitch // 2,
				max(self.k01_tracks['right']) + cfg_v.pitch // 2,
			]
		else:
			lx_right = [ die.xMax(), die.xMax() ]

		if self.k01_tracks['bot']:
			ly_bot = [
				min(self.k01_tracks['bot']) - cfg_h.pitch // 2,
				max(self.k01_tracks['bot']) + cfg_h.pitch // 2,
			]
		else:
			ly_bot = [ die.yMin(), die.yMin() ]

		if self.k01_tracks['top']:
			ly_top = [
				min(self.k01_tracks['top']) - cfg_h.pitch // 2,
				max(self.k01_tracks['top']) + cfg_h.pitch // 2,
			]
		else:
			ly_top = [ die.yMax(), die.yMax() ]

		# Left
		if self.k01_tracks['left']:
			odb.dbObstruction_create(self.reader.block,
				layer_v, lx_left[0], ly_bot[0], lx_left[1], ly_top[1])

		# Right
		if self.k01_tracks['right']:
			odb.dbObstruction_create(self.reader.block,
				layer_v, lx_right[0], ly_bot[0], lx_right[1], ly_top[1])

		# Bottom
		if self.k01_tracks['bot']:
			odb.dbObstruction_create(self.reader.block,
				layer_h, lx_left[0], ly_bot[0], lx_right[1], ly_bot[1])

		# Top
		if self.k01_tracks['top']:
			odb.dbObstruction_create(self.reader.block,
				layer_h, lx_left[0], ly_top[0], lx_right[1], ly_top[1])



class ModulePowerStrapper:

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


class RingPowerStrapper:

	def __init__(self, reader):
		# Save vars
		self.reader = reader

		# Find useful data
		tech = reader.db.getTech()

		self.layer = tech.findLayer('met3')
		self.tech = self.reader.db.getTech()
		self.via_rule = self.tech.findViaGenerateRule('M3M4_PR')
		self.vias = {}

	def find_ring_for_net(self, net):
		# Find all the boxes on met4
		boxes = []
		for sw in net.getSWires():
			for w in sw.getWires():
				# Skip vias
				if w.isVia():
					continue

				# Only met4/met5
				if w.getTechLayer().getName() != 'met4':
					continue

				boxes.append(w)

		# There should be none or 2
		if len(boxes) == 0:
			return None

		if len(boxes) != 2:
			raise RuntimeError(f'Unexpected boxes for net {net.getName():s}')

		# Sort and return
		boxes = sorted(boxes, key=lambda x:x.xMin())

		return {
			'l': boxes[0],
			'r': boxes[1],
		}

	def gen_via(self, vw, vh):
		# Find the rules for top/cut/bot
		met = []

		for i in range(self.via_rule.getViaLayerRuleCount()):
			# Get rule and associated layer
			r = self.via_rule.getViaLayerRule(i)
			ln = r.getLayer().getName()

			# Is it the cut ?
			if 'via' in ln.lower():
				cut_ln = ln
				cut = [ r.getRect().dx(), r.getRect().dy() ]
				spacing = r.getSpacing()

			# Metal
			elif 'met' in ln.lower():
				met.append(ln)

			# WTF ?
			else:
				raise RuntimeError('Unknown via rule')

		met = sorted(met)

		# Compute row / columns
		ncols = (vw // (cut[0] + spacing[0])) - 1
		nrows = (vh // (cut[1] + spacing[1])) - 1

		# Create via
		v = odb.dbVia.create(self.reader.block, f'prs_{vw:d}x{vh:d}')
		v.setViaGenerateRule(self.via_rule)

		# Configure params
		vp = v.getViaParams()

		vp.setBottomLayer(self.tech.findLayer(met[0]))
		vp.setCutLayer(self.tech.findLayer(cut_ln))
		vp.setTopLayer(self.tech.findLayer(met[1]))
		vp.setNumCutCols(ncols)
		vp.setNumCutRows(nrows)
		vp.setXCutSize(cut[0])
		vp.setYCutSize(cut[1])
		vp.setXCutSpacing(spacing[0])
		vp.setYCutSpacing(spacing[1])

		v.setViaParams(vp)

		# Done
		return v

	def get_via(self, vw, vh):
		k = (vw, vh)
		if k not in self.vias:
			self.vias[k] = self.gen_via(vw, vh)
		return self.vias[k]

	def strap_draw(self, sw, sxl, sxr, rxl, rxr, yb, yt):
		# Stripe
		odb.createSBoxes(sw, self.layer, [odb.Rect(sxl, yb, sxr, yt)], "STRIPE")

		via = self.tech.findVia('M3M4_PR')


		# Connecting via
		via = self.get_via(rxr-rxl, yt-yb)

		rxm = (rxl + rxr) // 2
		ym  = ( yb +  yt) // 2
		odb.createSBoxes(sw, via, [odb.Point(rxm, ym)], "STRIPE")

	def strap_bterm(self, bterm):
		# Die area
		die = self.reader.block.getDieArea()

		# Find all the rings boxes
		ring = self.find_ring_for_net(bterm.getNet())
		if ring is None:
			return

		# Create new SWire for our straps
		net = bterm.getNet()
		sw = odb.dbSWire.create(net, "ROUTED")

		# Scan all the boxes for that bterm and connect it
		# to the appropriate rail
		for bpin in  bterm.getBPins():
			for bbox in bpin.getBoxes():
				# Only process pins on side which should be met3
				if bbox.getTechLayer().getName() != 'met3':
					continue

				# Is pin left or right ?
				xl  = ring['r'].xMin()
				xr  = ring['l'].xMax()
				yb  = bbox.yMin()
				yt  = bbox.yMax()

				if bbox.xMin() < die.xMin():
					side = 'l'
					xl = bbox.xMin()

				elif bbox.xMax() > die.xMax():
					side = 'r'
					xr = bbox.xMax()

				else:
					# ???
					continue

				self.strap_draw(sw, xl, xr, ring[side].xMin(), ring[side].xMax(), yb, yt)

	def run(self):
		# Scan all power rails
		for bterm in self.reader.block.getBTerms():
			if bterm.getSigType() in ['POWER', 'GROUND']:
				self.strap_bterm(bterm)


class AnalogRouter:

	def __init__(self, reader, tti):
		# Save vars
		self.reader = reader
		self.tti    = tti

		# Create tech rules
		self.prepare_tech()

		# Find all analog switches
		self.asw = [
			inst
				for inst in self.reader.block.getInsts()
				if inst.getMaster().getName().startswith('tt_asw')
		]

	def prepare_tech(self):
		# Find tech and layers
		tech = self.reader.db.getTech()
		self.layer_bot = tech.findLayer('met3')
		self.layer_cut = tech.findLayer('via3')
		self.layer_top = tech.findLayer('met4')

		# Create via
		via_rule  = tech.findViaGenerateRule('M3M4_PR')

		v = odb.dbVia.create(self.reader.block, f'analog_via')
		v.setViaGenerateRule(via_rule)

		# Configure via params
		vp = v.getViaParams()

		vp.setBottomLayer(self.layer_bot)
		vp.setCutLayer(self.layer_cut)
		vp.setTopLayer(self.layer_top)

		vp.setNumCutCols(3)
		vp.setNumCutRows(3)
		vp.setXCutSize(200)
		vp.setYCutSize(200)
		vp.setXCutSpacing(200)
		vp.setYCutSpacing(200)
		vp.setXBottomEnclosure(90)
		vp.setYBottomEnclosure(60)
		vp.setXTopEnclosure(65)
		vp.setYTopEnclosure(65)

		v.setViaParams(vp)

		self.via = v

		# Create non-default rule
		self.ndr = ndr = odb.dbTechNonDefaultRule_create(self.reader.block, 'analog_track')
		for ln in [ 'li1', 'met1', 'met2', 'met3', 'met4', 'met5' ]:
			ly = tech.findLayer(ln)
			lr = odb.dbTechLayerRule_create(ndr, ly)
			lr.setWidth(900)
			lr.setSpacing(2700)

	def _asw_group(self, lst):
		grp = []
		for c_ymin, c_ymax in lst:
			# Mid position
			c_ymid  = (c_ymax + c_ymin) // 2
			c_yspan = (c_ymax - c_ymin)

			# Scan existing group
			for i, (g_ymin, g_ymax) in enumerate(grp):
				g_ymid = (g_ymax + g_ymin) // 2
				if abs(g_ymid - c_ymid) < (2 * c_yspan):
					grp[i] = ( min([g_ymin, c_ymin]), max([g_ymax, c_ymax]) )
					break

			else:
				grp.append( (c_ymin, c_ymax) )

		return grp

	def _asw_power_solo(self, asw):
		# Process each power pin
		via = None
		to_connect = []

		for it in asw.getITerms():
			# Only consider power/ground
			if it.getSigType() not in ['POWER', 'GROUND']:
				continue

			# Check if there is a via inside the pin already
			bbox  = it.getBBox()
			net   = it.getNet()
			found = False

			for sw in net.getSWires():
				for sb in sw.getWires():
					if not sb.isVia():
						continue

					if not bbox.intersects(odb.Point(*sb.getViaXY())):
						continue

					via = sb.getBlockVia()
					found = True
					break
				else:
					continue

				break

			# If not, add to the list
			else:
				to_connect.append(it)

		# If we found no via, we have no reference
		if via is None:
			raise RuntimeError('No via reference found')

		# Process the connections
		for it in to_connect:
			# Find the closest 'met5' stripe
			it_bbox = it.getBBox()
			net     = it.getNet()

			m_sb   = None
			m_dist = None

			for sw in net.getSWires():
				for sb in sw.getWires():
					# Don't consider via
					if sb.isVia():
						continue

					# Don't consider anything else than met5
					if sb.getTechLayer().getName() != 'met5':
						continue

					# Must be stripe
					if sb.getWireShapeType() != 'STRIPE':
						continue

					# Check we're within in horizontally
					if (sb.xMin() > it_bbox.xMin()) or (sb.xMax() < it_bbox.xMax()):
						continue

					# Distance
					d = ((sb.yMin() + sb.yMax()) // 2) - it_bbox.yCenter()

					if (m_dist is None) or (abs(d) < abs(m_dist)):
						m_sb   = sb
						m_dist = d

			# Prepare to add special routing
			net = it.getNet()
			sw = odb.dbSWire.create(net, "ROUTED")

			# Extend the stripe to it
			xl = it_bbox.xMin()
			xv = it_bbox.xCenter()
			xr = it_bbox.xMax()

			yv = (m_sb.yMin() + m_sb.yMax()) // 2

			if m_dist > 0:
				yb = it_bbox.yMin()
				yt = m_sb.yMax()
			else:
				yb = m_sb.yMin()
				yt = it_bbox.yMax()

			odb.createSBoxes(sw, via.getBottomLayer(), [odb.Rect(xl, yb, xr, yt)], "STRIPE")

			# Add via
			odb.createSBoxes(sw, via, [odb.Point(xv, yv)], "STRIPE")

	def _asw_power_pair(self, asw_bot, asw_top):
		# Process each power pin
		for it_bot in asw_bot.getITerms():
			# Only consider power/ground
			if it_bot.getSigType() not in ['POWER', 'GROUND']:
				continue

			# Get matching iterm
			it_top = asw_top.findITerm(it_bot.getMTerm().getName())

			# Coordinates
			bbox_bot = it_bot.getBBox()
			bbox_top = it_top.getBBox()

			xl = bbox_bot.xMin()
			xr = bbox_bot.xMax()
			yb = bbox_bot.yMin()
			yt = bbox_top.yMax()

			# Create strap
			net = it_bot.getNet()
			sw = odb.dbSWire.create(net, "ROUTED")
			odb.createSBoxes(sw, self.layer_top, [odb.Rect(xl, yb, xr, yt)], "STRIPE")

	def asw_power(self):
		# Group the analog switch per x coordinate
		xgrp = {}
		for inst in self.asw:
			xgrp.setdefault(inst.getLocation()[0], set()).add(inst)

		# Try to pair them
		asw_grp = []

		for grp in xgrp.values():
			while len(grp):
				# Pick one
				asw0 = grp.pop()

				# Scan the rest of the group for a potential pair
				for inst in grp:
					# Pair must have opposite orientation
					if inst.getOrient() == asw0.getOrient():
						continue

					# Pair must be close
					dist  = abs(inst.getLocation()[1] - asw0.getLocation()[1])
					limit = asw0.getBBox().getDY() * 3

					if dist < limit:
						asw1 = inst
						break
				else:
					# Nothing found
					asw_grp.append( (asw0, None) )
					continue

				# We found a pair, sort them as (bot, top)
				if asw0.getLocation()[1] > asw1.getLocation()[1]:
					asw_grp.append( (asw1, asw0) )
				else:
					asw_grp.append( (asw0, asw1) )

				# Also remove the match from the set
				grp.remove(asw1)

		# Process each group
		for asw0, asw1 in asw_grp:
			if asw1 is None:
				self._asw_power_solo(asw0)
			else:
				self._asw_power_pair(asw0, asw1)

	def asw_bus(self):
		# Offset
		OFFSET = 1350

		# Load data file
		data = yaml.load(open('route_data.yaml'), yaml.FullLoader)['analog']

		# Look at all analog switches to find extent
		#  First scan to group per block
		abi  = {}
		nets = set()

		for inst in self.asw:
			# Which block does it belong do
			blk = inst.getName().rsplit('.',1)[0]

			# Record position and and net
			it = inst.findITerm('bus')

			xpos = it.getAvgXY()[1]
			net  = it.getNet()

			bi = abi.setdefault(blk, ([], []))
			bi[0].append(xpos)
			bi[1].append(net.getName())

			nets.add(net.getName())

		#  Then for each net
		for net_name in nets:
			# Accumulate all relevant X positions
			xpl = []
			for blk, bi in abi.items():
				if net_name in bi[1]:
					xpl.extend(bi[0])

			# Get actual net, associated bterm and routing infos
			net = self.reader.block.findNet(net_name)
			bterm = net.getBTerms()[0]
			bbox  = bterm.getBBox()
			ri = data[bterm.getName()]

			# Actual IO position
			_, xp_bterm, yp_bterm = bterm.getFirstPinLocation()

			# Side of the IO
			w = self.ndr.getLayerRule(self.layer_bot).getWidth()
			mid = self.reader.block.getDieArea().dx() // 2

			if xp_bterm > mid:
				# IO goes right side
				xp_start = min(xpl) - OFFSET
				xp_pad   = bbox.xMin() - (w//2)

			else:
				# IO goes left side
				xp_start = max(xpl) + OFFSET
				xp_pad   = bbox.xMax() + (w//2)

			# Prepare for routing
			net.setNonDefaultRule(self.ndr)

			wire = odb.dbWire.create(net)

			encoder = odb.dbWireEncoder()
			encoder.begin(wire)

			# Create the 'bus' part
			encoder.newPath(self.layer_bot, 'FIXED', self.ndr.getLayerRule(self.layer_bot))

			encoder.addPoint(xp_start, ri[0])
			encoder.addPoint(ri[1],    ri[0])
			encoder.addPoint(ri[1],    yp_bterm)
			encoder.addPoint(xp_pad,   yp_bterm)

			encoder.newPath(self.layer_bot, 'FIXED')
			encoder.addPoint(xp_pad,   yp_bterm)
			encoder.addPoint(xp_bterm, yp_bterm)

			# Create all the stubs
			for inst in self.asw:
				# Connected to this net ?
				it = inst.findITerm('bus')

				if it.getNet().getName() != net_name:
					continue

				# Position of terminal
				_, xp_iterm, yp_iterm = it.getAvgXY()

				# Offset Shift
				if yp_iterm > ri[0]:
					xp_int = xp_iterm + OFFSET
					yp_int = yp_iterm - OFFSET * 2
				else:
					xp_int = xp_iterm - OFFSET
					yp_int = yp_iterm + OFFSET * 2

				# Create stub
				encoder.newPath(self.layer_top, 'FIXED', self.ndr.getLayerRule(self.layer_top))

				encoder.addPoint(xp_iterm, yp_iterm)
				encoder.addPoint(xp_iterm, yp_int)
				encoder.addPoint(xp_int,   yp_int)
				encoder.addPoint(xp_int,   ri[0])
				encoder.addVia(self.via)

			# Done routing
			encoder.end()

	def asw_mod(self):
		# Scan all switches
		for inst_asw in self.asw:
			# Get the module connection
			it_asw = inst_asw.findITerm('mod')

			# Get net
			net = it_asw.getNet()
			net.setNonDefaultRule(self.ndr)

			# Get the two iterms to connect
			its = net.getITerms()
			if len(its) != 2:
				raise RuntimeError('Too many module connections')

			it_mod = its[0] if (its[1].this == it_asw.this) else its[1]

			_, x0, y0 = it_mod.getAvgXY()
			_, x1, y1 = it_asw.getAvgXY()

			# Prepare to route
			wire = odb.dbWire.create(net)

			encoder = odb.dbWireEncoder()
			encoder.begin(wire)

			# Workaround for narrow pads
			# Remove in TT7 when analog template is updated ...
			w = self.ndr.getLayerRule(self.layer_top).getWidth()

			encoder.newPath(self.layer_top, 'FIXED')
			encoder.addPoint(x0, y0)
			y0 = (it_mod.getBBox().yMin() - (w//2)) if (y0 > y1) else (it_mod.getBBox().yMax() + (w//2))
			encoder.addPoint(x0, y0)

			# Path
			encoder.newPath(self.layer_top, 'FIXED', self.ndr.getLayerRule(self.layer_top))
			encoder.addPoint(x0, y0)

			if x0 != x1:
				ym = (y0 + y1) // 2
				encoder.addPoint(x0, ym)
				encoder.addPoint(x1, ym)

			encoder.addPoint(x1, y1)

			# Done routing
			encoder.end()

	def run(self):
		self.asw_power()
		self.asw_bus()
		self.asw_mod()


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
	r.route_k01_global()
	r.route_k01_gpio()
	r.create_k01_obs()
	r.route_pad()
	r.route_um_tieoffs()

	# Create the module power straps
	p = ModulePowerStrapper(reader, tti)
	p.run()

	# Create the ring power straps
	p = RingPowerStrapper(reader)
	p.run()

	# Analog router
	a = AnalogRouter(reader, tti)
	a.run()

if __name__ == "__main__":
	route()
