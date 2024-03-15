#!/usr/bin/env python3

#
# Tiny Tapeout
#
# Module Placer (Logical Grid)
#
# Copyright (c) 2023 Sylvain Munaut <tnt@246tNt.com>
# SPDX-License-Identifier: Apache-2.0
#

import yaml


__all__ = [ 'ModuleSlot', 'ModulePlacer' ]


class ModuleSlot:

	def __init__(self, placer, cfg_data):
		self.placer = placer
		self.name   = cfg_data['name']
		self.pos_x  = cfg_data.get('x')
		self.pos_y  = cfg_data.get('y')
		self.width  = cfg_data.get('width', 1)
		self.height = cfg_data.get('height', 1)
		self.pg_vdd = cfg_data.get('pg_vdd', True)
		self.analog = cfg_data.get('analog', False)

	def as_dict(self):
		return {
			'name':   self.name,
			'x':      self.pos_x,
			'y':      self.pos_y,
			'mux_id': self.mux_id,
			'blk_id': self.blk_id,
			'width':  self.width,
			'height': self.height,
			'pg_vdd': self.pg_vdd,
			'analog': self.analog,
		}

	@property
	def mux_id(self):
		return self.placer.p2l(self.pos_x, self.pos_y)[0]

	@property
	def blk_id(self):
		return self.placer.p2l(self.pos_x, self.pos_y)[1]


class ModulePlacer:

	def __init__(self, cfg, mod_file, verbose=False):
		# Save config
		self.cfg = cfg
		self.verbose = verbose

		# Run placement
		self.gen_grid()
		self.load_modules(mod_file)
		self.place_modules()

	def gen_grid(self):
		self.lgrid = {}
		self.pgrid = {}
		self.pgrid_free = set()
		for y in range(self.cfg.tt.grid.y):
			for x in range(self.cfg.tt.grid.x):
				self.pgrid_free.add( (x, y) )

	def p2l(self, pos_x, pos_y):
		# Grid dimensions
		gx = self.cfg.tt.grid.x
		gy = self.cfg.tt.grid.y

		# Position vs middle point
		pos_x -= gx // 2
		pos_y -= gy // 2

		# TopBottom / LeftRight
		tb = pos_y >= 0
		lr = pos_x >= 0

		# Logical position
		pos_y = abs(pos_y + 1 - tb)
		pos_x = abs(pos_x + 1 - lr)

		mux_id = ((pos_y >> 1) << 2) | (lr << 1) | tb
		blk_id = (pos_x << 1) | (pos_y & 1)

		return mux_id, blk_id

	def l2p(self, mux_id, blk_id):
		# Grid dimensions
		gx = self.cfg.tt.grid.x
		gy = self.cfg.tt.grid.y

		# TopBottom / LeftRight
		tb = 1 if (mux_id & 1) else 0
		lr = 1 if (mux_id & 2) else 0

		# Physical position
		pos_y = (gy // 2) - 1 + tb + (2 * tb - 1) * (((mux_id >> 2) << 1) + (blk_id & 1))
		pos_x = (gx // 2) - 1 + lr + (2 * lr - 1) * (blk_id >> 1)

		return pos_x, pos_y

	def load_modules(self, mod_file):
		# Load raw data from YAML
		with open(mod_file, 'r') as fh:
			data = yaml.load(fh, Loader=yaml.FullLoader)

		# Create and pre-check each module
		self.modules = []
		for mc in data['modules']:
			# Save data
			mod = ModuleSlot(self, mc)
			self.modules.append(mod)

			# Size & Position limits
			if mod.height not in [1,2]:
				raise RuntimeError(f"Module '{mod.name:s}' has invalid height {mod.height:d}")

			if mod.width not in [1,2,3,4,8]:
				raise RuntimeError(f"Module '{mod.name:s}' has invalid width {mod.width:d}")

			if (mod.pos_x is not None) and (
					(mod.pos_x < 0) or
					(mod.pos_x >= self.cfg.tt.grid.x)
				):
				raise RuntimeError(f"Module '{mod.name:s}' has invalid X position {mod.pos_x:d}")

			if (mod.pos_y is not None) and (
					(mod.pos_y < 0) or
					(mod.pos_y >= self.cfg.tt.grid.y)
				):
				raise RuntimeError(f"Module '{mod.name:s}' has invalid Y position {mod.pos_y:d}")

	def save_modules(self, mod_file):
		data = {
			'modules': [ m.as_dict() for m in self.modules ],
		}
		with open(mod_file, 'w') as fh:
			fh.write(yaml.dump(data))

	def _sites_for_module(self, mod, pos_x, pos_y):
		sx = -1 if pos_x >= (self.cfg.tt.grid.x // 2) else 1
		sy = -1 if ((pos_y & 1) == 0) else 1
		for oy in range(mod.height):
			for ox in range(mod.width):
				yield (pos_x+sx*ox, pos_y+sy*oy)

	def _site_suitable(self, mod, pos_x, pos_y):
		# Check all positions exist and are free
		for (ox, oy) in self._sites_for_module(mod, pos_x, pos_y):
			if (ox, oy) not in self.pgrid_free:
				return False

		# For multi-width, check we don't cross mid boundary
		if mod.width > 1:
			mid_x = self.cfg.tt.grid.x // 2
			sx = -1 if pos_x >= mid_x else 1
			if (pos_x >= mid_x) ^ ((pos_x + sx * (mod.width - 1)) >= mid_x):
				return False

		# All checks out
		return True

	def _find_xy_for_module(self, mod):
		# Scan the whole grid in order and check if suitable
		for y in range(self.cfg.tt.grid.y):
			for x in range(self.cfg.tt.grid.x):
				if self._site_suitable(mod, x, y):
					return x, y
		return None, None

	def _find_y_for_module(self, mod):
		for y in range(self.cfg.tt.grid.y):
			if self._site_suitable(mod, mod.pos_x, y):
				return mod.pos_x, y
		return None, None

	def _find_x_for_module(self, mod):
		for x in range(self.cfg.tt.grid.x):
			if self._site_suitable(mod, x, mod.pos_y):
				return x, mod.pos_y
		return None, None

	def _place_module(self, mod):
		# Find final X, Y
		if (mod.pos_x is None) and (mod.pos_y is None):
			x, y = self._find_xy_for_module(mod)
		elif (mod.pos_x is None):
			x, y = self._find_x_for_module(mod)
		elif (mod.pos_y is None):
			x, y = self._find_y_for_module(mod)
		elif self._site_suitable(mod, mod.pos_x, mod.pos_y):
			x, y = mod.pos_x, mod.pos_y
		else:
			x = y = None

		# Valid ?
		if (x is None) or (y is None):
			raise RuntimeError(f"Module '{mod.name:s}' couldn't be placed")

		# Actually place it
		mod.pos_x = x
		mod.pos_y = y

		# And in the grid
		self.pgrid[ (x, y) ] = mod
		self.lgrid[ self.p2l(x, y) ] = mod

		# And remove the sites from the free list
		for (ox, oy) in self._sites_for_module(mod, x, y):
			self.pgrid_free.remove( (ox, oy) )

		# Debug
		if self.verbose:
			print(f"Module [{mod.width:d}x{mod.height:d}] placed at ({mod.pos_x:2d}, {mod.pos_y:2d}): '{mod.name:s}'")

	def _place_modules_group(self, mods):
		# Sort the modules by size
		mods = sorted(mods, key=lambda m: (m.height, m.width), reverse=True)

		# Attempt to place them one by one
		for m in mods:
			self._place_module(m)

	def place_modules(self):
		# Sort modules into 3 sets
		full_placed = []
		semi_placed = []
		auto_placed = []

		for m in self.modules:
			if   (m.pos_x is not None) and (m.pos_y is not None):
				full_placed.append(m)
			elif (m.pos_x is not None) or  (m.pos_y is not None):
				semi_placed.append(m)
			else:
				auto_placed.append(m)

		# Place them from most constrained to less constrained
		self._place_modules_group(full_placed)
		self._place_modules_group(semi_placed)
		self._place_modules_group(auto_placed)

