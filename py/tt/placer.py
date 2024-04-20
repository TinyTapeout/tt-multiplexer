#!/usr/bin/env python3

#
# Tiny Tapeout
#
# Module Placer (Logical Grid)
#
# Copyright (c) 2023 Sylvain Munaut <tnt@246tNt.com>
# SPDX-License-Identifier: Apache-2.0
#

from collections import namedtuple

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
		self.analog = cfg_data.get('analog', {})

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

		# Current place mode
		self.analog_fill = False

		# Extract analog muxes positions
		self.mux_analog = set()
		if hasattr(self.cfg.tt, 'analog'):
			for grp in self.cfg.tt.analog:
				self.mux_analog.update(grp['mux_id'])

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

	def la2ld(self, amux_id, ablk_id):
		"""
		Converts a logical position on an 'analog mux' to the matching position
		on a 'digital mux' where the module actually is located
		"""
		# Side toward or away from controller
		if ablk_id & 1:
			# Away from the controller
			dmux_id = amux_id + 4
			dblk_id = ablk_id ^ 1

		else:
			# Toward the controller
			if amux_id >= 4:
				# Normal case
				dmux_id = amux_id - 4
				dblk_id = ablk_id ^ 1

			else:
				# We're crossing over the other side of the controller
				dmux_id = amux_id ^ 1
				dblk_id = ablk_id ^ 1

		return dmux_id, dblk_id

	def ld2la(self, dmux_id, dblk_id):
		"""
		Converts a logical position on an 'digital mux' to the matching position
		on a 'analog mux' where the module analog ports would be
		"""
		# Turns out it's an involution
		return self.la2ld(dmux_id, dblk_id)

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

			if mod.width not in [1,2,3,4,6,8]:
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
		# Check this is a connectable position
		mux_id, blk_id = self.p2l(pos_x, pos_y)
		if mux_id in self.mux_analog:
			return False

		# If in analog fill mode, that slot must be facing an analog slot
		if self.analog_fill:
			amux_id, ablk_id = self.ld2la(mux_id, blk_id)
			if not amux_id in self.mux_analog:
				return False

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

	def _module_placed(self, mod):
		if (mod.pos_x is None) or (mod.pos_y is None):
			return False
		return self.pgrid.get((mod.pos_x, mod.pos_y)) == mod

	def _place_module(self, mod):
		# Already dealt with ?
		if self._module_placed(mod):
			return

		# If we're trying to fill analog slots, only height=2 matters
		if self.analog_fill and (mod.height != 2):
			return

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
			if self.analog_fill:
				return
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
		# Deal with analog modules first if we support analog
		if self.mux_analog:
			ap = AnalogPlacer(self)
			ap.place_modules(self.modules)

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
			# Fully placed are just checked
		self._place_modules_group(full_placed)

			# Semi/Auto trying to fill analog positions first
		self.analog_fill = True
		self._place_modules_group(semi_placed)
		self._place_modules_group(auto_placed)

			# And then normal mode
		self.analog_fill = False
		self._place_modules_group(semi_placed)
		self._place_modules_group(auto_placed)


AnalogPin = namedtuple('AnalogPin', 'num y mods dedicated')

class AnalogPinGroup:

	def __init__(self, placer, cfg_grp):
		# Save placer & Config
		self.placer = placer
		self.cfg = cfg = placer.cfg

		# Save list of pins and Y position and assigned modules
		self.pins = dict([
			(k, AnalogPin(k, v, [], k in cfg_grp.get('dedicated',[])))
				for k, v in cfg_grp['pins'].items()
		])

		# Estimate mux position
		mux_id = cfg_grp['mux_id'][0]

		h_avail = cfg.pdk.die.height - (cfg.pdk.die.margin.top + cfg.pdk.die.margin.top)
		h_mid   = cfg.pdk.die.margin.bottom + h_avail // 2
		h_mux   = h_avail // (cfg.tt.grid.y // 2)

		d = round(((mux_id >> 2) + 0.5) * h_mux)
		if mux_id & 1:
			self.pos_y = h_mid + d
		else:
			self.pos_y = h_mid - d

		# Generate free spots in order of preference
		mux_ids = cfg_grp['mux_id']
		l = len(mux_ids)
		n = cfg.tt.grid.x // 2

		self.pos_free = pos_free = []

		if l == 1:
			# Only one mux, prefer outside of the mux (closer to pad frame)
			for x in range(n):
				pos_free.append( (mux_ids[0], 2*(n-x-1) + 0) )
				pos_free.append( (mux_ids[0], 2*(n-x-1) + 1) )

		elif l == 2:
			# Check they are on the same line
			if (mux_ids[0] & ~2) != (mux_ids[1] & ~2):
				raise RuntimeError("Two mux in a group are not on the same line")

			# The first mux we prefer the outside first
			for x in range(n):
				pos_free.append( (mux_ids[0], 2*(n-x-1) + 0) )
				pos_free.append( (mux_ids[0], 2*(n-x-1) + 1) )

			# The second mux we prefer the inside first
			for x in range(n):
				pos_free.append( (mux_ids[1], 2*x + 0) )
				pos_free.append( (mux_ids[1], 2*x + 1) )

		else:
			# ?!?
			raise RuntimeError("Can't have more than 2 mux per group !")

		# Keep a copy of all positions in this group
		self.pos_all = set(pos_free)

		# Debug print
		if False:
			for amux_id, ablk_id, inv in pos_free:
				dmux_id, dblk_id = self.placer.la2ld(amux_id, ablk_id)
				ax, ay = self.placer.l2p(amux_id, ablk_id)
				dx, dy = self.placer.l2p(dmux_id, dblk_id)
				print(f'{amux_id:2d}/{ablk_id:2d} - {dmux_id:2d}/{dblk_id:2d} | {ax:2d}/{ay:2d} - {dx:2d}/{dy:2d}')
			print("-----")

	def pick_pins_in_set(self, pins, n):
		# Sort by user * distance
		return sorted(pins, key=lambda p: (len(p.mods) + 1) * abs(p.y - self.pos_y))[0:n]

	def pick_pins_for_module(self, m):
		# How many pins needed ?
		n = len([x for x in m.analog.values() if x is None])

		# Build a map of # users -> pin list
		use_map = {}
		for pin in self.pins.values():
			if pin.dedicated:
				continue
			use_map.setdefault(len(pin.mods), []).append(pin)

		use_cnt = sorted(use_map.keys())

		# Check the least 2 used groups see if there are enough pins
		for i in range(min([len(use_cnt), 2])):
			if len(use_map[use_cnt[i]]) >= n:
				return self.pick_pins_in_set(use_map[use_cnt[i]], n)

		# Just use the N least used pins
		pl = []

		for k in use_cnt:
			pl.extend(use_map[k])
			if len(pl) >= n:
				break

		if len(pl) < n:
			return None

		return self.pick_pins_in_set(pl, n)

	def pick_pos_for_module(self, mod):
		# Is there even space ?
		if mod.width > len(self.pos_free):
			return None

		# Scan for a match
		for mux_id, blk_id in self.pos_free:
			# Check if it fits
			fit = True
			for i in range(mod.width):
				if (mux_id, blk_id - 2*i) not in self.pos_free:
					fit = False
					break

			# Yes ?
			if fit:
				return mux_id, blk_id

		# No match found
		return None

	def cost(self, mod, pins):
		# If it doesn't fit, give up
		if pins is None:
			return None

		if self.pick_pos_for_module(mod) is None:
			return None

		# FIXME:
		#  Higher cost if less free slots
		#  Higher cost if more analog pins used
		#  Higher cost depending on min-max pin loading difference
		return sum([len(pin.mods) for pin in self.pins.values()])

	def place(self, mod, pins):
		# Actually assign the pins to the module
		for k,v in mod.analog.items():
			if v is not None:
				continue
			pin = pins.pop()
			pin.mods.append(mod)
			mod.analog[k] = pin.num

		# Does the module already have a position ?
		if (mod.pos_x is not None) and (mod.pos_y is not None):
			# Yes, use that
			mux_id, blk_id = self.placer.la2ld(*self.placer.p2l(mod.pos_x, mod.pos_y))

		else:
			# Nope, Find a position for it
			mux_id, blk_id = self.pick_pos_for_module(mod)

			# Assign it as constraint
			x, y = self.placer.l2p(*self.placer.la2ld(mux_id, blk_id))

			mod.pos_x = x
			mod.pos_y = y

		# Remove from free list
		for i in range(mod.width):
			self.pos_free.remove( (mux_id, blk_id - 2*i) )

	def is_pos_in_group(self, mux_id, blk_id):
		return (mux_id, blk_id) in self.pos_all

	def mark_used(self, mux_id, blk_id, width=1):
		# Remove from free list
		for i in range(width):
			self.pos_free.remove( (mux_id, blk_id - 2*i) )


class AnalogPlacer:

	def __init__(self, placer):
		# Save placer
		self.placer = placer

		# Create the pin groups
		self.groups = [AnalogPinGroup(placer, g) for g in placer.cfg.tt.analog]

	def place_modules(self, mods):
		# List of modules attached to a group by constrain
		# (either manual placement or manual pins)
		mods_fixed = {}

		# Check modules with fixed position and marked those as occupied
		for m in mods:
			# If not pre-placed, will be dealt with later, skip
			if (m.pos_x is None) and (m.pos_y is None):
				continue

			# If it's semi-placed
			if (m.pos_x is None) ^ (m.pos_y is None):
				if m.analog:
					# It's analog, we don't support semi placed
					raise RuntimeError(f'Module {mod.name} is analog and partially placed, not supported')

				else:
					# Not analog module, will be dealt with later
					continue

			# Module has a fixed position, find analog pin groups
			mux_id, blk_id = self.placer.ld2la(*self.placer.p2l(m.pos_x, m.pos_y))

			for g in self.groups:
				if g.is_pos_in_group(mux_id, blk_id):
					grp = g
					break

			else:
				# Position is not in any group
				if m.analog:
					# It's analog and fixed in a position not supporting analog
					raise RuntimeError(f'Module {m.name} is analog and constrained to non-analog position')

				else:
					# Ok, fine, will be dealt with later
					continue

			# Is the module analog ?
			if m.analog:
				# Yes, Record the associated group
				mods_fixed[m] = grp
			else:
				# No, we just need to prevent anything from being placed there
				grp.mark_used(mux_id, blk_id, m.width)

		# Collect all modules with analog pins
		analog_mods = [m for m in mods if len(m.analog)]

		# Sort them
		analog_mods.sort(key=lambda m: m.width * len(m.analog) * len(m.analog), reverse=True)

		# Scan once to check for pre-assigned pins
		for m in analog_mods:
			# No group identified yet ?
			grp = mods_fixed.get(m)

			# Scan pins
			for v in m.analog.values():
				if v is None:
					continue

				# Find which group it belongs to
				for g in self.groups:
					if v in g.pins:
						# Check consistency
						if grp is None:
							grp = g
						elif grp != g:
							raise RuntimeError(f'Module {mod.name} has assigned analog pins in several groups or in a group different than its forced position')

						# Mark pin as used in the group
						grp.pins[v].mods.append(m)

				# If we have a group, keep it
				mods_fixed[m] = grp

		# Scan those a second time to assign pins in the same group
		for m, grp in mods_fixed.items():
			pins = grp.pick_pins_for_module(m)
			grp.place(m, pins)

		# Finally place the rest
		for m in analog_mods:
			# If it was processed, skip
			if m in mods_fixed:
				continue

			# Pick pins and Evaluate cost for each group and pick best
			l = []

			for grp in self.groups:
				pins = grp.pick_pins_for_module(m)
				if pins is None:
					continue

				cost = grp.cost(m, pins)
				if cost is None:
					continue

				l.append( (grp, pins, cost) )

			if len(l) == 0:
				raise RuntimeError(f"Analog module {m.name} couldn't be placed")

			grp, pins, cost = sorted(l, key=lambda gp: gp[2])[0]

			# Place module in it
			grp.place(m, pins)
