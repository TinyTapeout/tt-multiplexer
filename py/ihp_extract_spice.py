#!/usr/bin/env python3

#
# Extract iHP TinyTapeout top level connectivity for LVS
# Copyright (c) 2024 Sylvain Munaut <tnt@246tNt.com>
#

import re
import sys

from collections import namedtuple

import gdstk



LAYER_STACK = [
    8,      # Metal1
    19,     # Via1
    10,     # Metal2
    29,     # Via2
    30,     # Metal3
    49,     # Via3
    50,     # Metal4
    66,     # Via4
    67,     # Metal5
    125,    # TopVia1
    126,    # TopMetal1
    133,    # TopVia2
    134,    # TopMetal2
]

DWG_DT = 0
PIN_DT = 2
TXT_DT = 25


def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)


def num_sort(in_lst):
	def rewrite_num(n):
		return f"{int(n[0]):05d}"
	return sorted(in_lst, key=lambda entry: re.sub(r'(\d+)', rewrite_num, entry))


class BoundingBox(namedtuple("BoundingBox", "x0 y0 x1 y1")):

	__slots__ = []

	@classmethod
	def make(kls, p):
		b = p.bounding_box()
		return kls(b[0][0], b[0][1], b[1][0], b[1][1])

	def intersect(self, other):
		return (
			(self.x0  <= other.x1) and
			(other.x0 <= self.x1 ) and
			(self.y0  <= other.y1) and
			(other.y0 <= self.y1 )
		)

	def center(self):
		return (
			(self.x0 + self.x1) / 2,
			(self.y0 + self.y1) / 2,
		)


class Polygon:

	__slots__ = [ 'gp', 'bbox', 'pad', 'net' ]

	def __init__(self, gp, idx=None, pad=None):
		self.gp   = gp
		self.bbox = BoundingBox.make(gp)
		self.pad  = pad
		self.net  = None

	def intersect(self, other):
		# If the bounding box don't intersect, the polygons don't either
		if not self.bbox.intersect(other.bbox):
			return False

		# Check if any point of self are inside other or vice-versa
		if not other.gp.contain_any(*self.gp.points) and not self.gp.contain_any(*other.gp.points):
			# Nope, try the intersection
			if not gdstk.boolean(self.gp, other.gp, 'and'):
				return False

		return True


class NetlistExtractor:

	def __init__(self):
		self.net_id_nxt = 0
		self.ly_polys = {}
		self.pads = {}


	def flatten_via(self, cell):
		# Remove all reference to anything not a VIA
		rta = []
		for r in list(cell.references):
			if not r.cell_name.startswith('VIA'):
				cell.remove(r)
				rta.append(r)

		# Flatten
		cell.flatten()

		# Restore references
		for r in rta:
			cell.add(r)


	def simplify_cell(self, cell):

		# Create a new cell
		new_cell = gdstk.Cell(cell.name + '_bb')

		# Process each metal layer
		for ly_num in LAYER_STACK[::2]:
			# Grab all drawing polygons
			p_dwg = cell.get_polygons(layer=ly_num, datatype=DWG_DT, depth=0)

			# Grab all pins polygons
			p_pin = cell.get_polygons(layer=ly_num, datatype=PIN_DT, depth=0)

			# Grab all labels
			lbls = cell.get_labels(layer=ly_num, texttype=TXT_DT, depth=0)
			lbls_pos = [l.origin for l in lbls]

			# Process pins
			for p in p_pin:
				# Identify label
				lm = p.contain(*lbls_pos)
				if isinstance(lm, bool):
					lm = [lm]
				nm = sum(lm)

				pin_name = lbls[lm.index(True)].text if nm else None

				if nm > 1:
					eprint(f"[!] Pin with multiple labels ... using '{pin_name}'")

				# Fallback to property
				if pin_name is None:
					pin_name = p.get_gds_property(1)

				# At this point we really need a name
				if pin_name is None:
					eprint("[!] Pin without name ignored !")
					continue

				# AND with all drawing
				npl = gdstk.boolean(p, p_dwg, 'and')

				# Add to the target cell with name as property
				for np in npl:
					# Add in drawing layer
					np.layer = ly_num
					np.datatype = DWG_DT
					np.set_gds_property(1, pin_name)
					new_cell.add(np)

					# Add a copy in the pin layer
					np = np.copy()
					np.layer = ly_num
					np.datatype = PIN_DT
					new_cell.add(np)

					# Add a label
					new_cell.add(gdstk.Label(
						pin_name,
						origin = BoundingBox.make(np).center(),
						layer = ly_num,
						texttype = TXT_DT
					))

		# Return new cell
		return new_cell


	def simplify_subcells(self, cell):
		sc = {}
		for r in cell.references:
			if r.cell_name not in sc:
				sc[r.cell_name] = self.simplify_cell(r.cell)
			r.cell = sc[r.cell_name]


	def reference_flatten(self, ref):
		new_cell = gdstk.Cell('ref_' + str(hash(ref)))
		new_cell.add(ref.copy())
		new_cell.flatten()
		return new_cell


	def collect_metal_polygons(self):
		# Simplify top level
		top_base = self.simplify_cell(self.top)

		# Flatten all references
		ref_flat = [
			(ref, self.reference_flatten(ref))
			for ref in self.top.references
		]

		# Process each metal layer
		for ly_num in LAYER_STACK[::2]:

			# Get local polygons
			ly_polys = self.top.get_polygons(layer=ly_num, datatype=DWG_DT, depth=0)

			# Simplify geometry
			ly_polys = gdstk.boolean(ly_polys, [], 'or')
			for p in ly_polys:
				p.layer = ly_num
				p.datatype = DWG_DT

			# Wrap them
			self.ly_polys[ly_num] = [ Polygon(p) for p in ly_polys ]

			# Add polygons from our simplified self for pads
			top_pad_poly = [
				Polygon(p,
					pad = (None, p.get_gds_property(1))
				)
				for i,p in enumerate(top_base.polygons)
				if (p.layer == ly_num) and (p.datatype == DWG_DT)
			]

			self.ly_polys[ly_num].extend(top_pad_poly)

			# Keep a list of polys per pads
			for p in top_pad_poly:
				self.pads.setdefault(p.pad, []).append(p)

			# Process simplified sub cells
			for ref, sc in ref_flat:

				# Add polygons to list
				sc_pad_poly = [
					Polygon(p,
						pad = (ref, p.get_gds_property(1))
					)
					for p in sc.polygons
					if (p.layer == ly_num) and (p.datatype == DWG_DT)
				]

				self.ly_polys[ly_num].extend(sc_pad_poly)

				# Keep a list of polys per pads
				for p in sc_pad_poly:
					self.pads.setdefault(p.pad, []).append(p)

			# Sort the polygons by x coordinate
			self.ly_polys[ly_num].sort(key=lambda x: x.bbox.x0)


	def collect_via_polygons(self):
		# Scan all "via" layers
		for ly_num in LAYER_STACK[1::2]:

			# Get local polygons
			ly_polys = self.top.get_polygons(layer=ly_num, datatype=DWG_DT, depth=0)

			# Simplify geometry
			ly_polys = gdstk.boolean(ly_polys, [], 'or')
			for p in ly_polys:
				p.layer = ly_num
				p.datatype = DWG_DT

			# Wrap them
			self.ly_polys[ly_num] = [ Polygon(p) for p in ly_polys ]

			# Sort by x coordinates
			self.ly_polys[ly_num].sort(key=lambda x: x.bbox.x0)


	def merge_nets(self, nets, n1, n2):
		# Check which will result in less re-assignement
		if len(nets[n1]) > len(nets[n2]):
			old_net = n2
			new_net = n1
		else:
			old_net = n1
			new_net = n2

		# Reassign polygons
		for pi in nets[old_net]:
			pi.net = new_net

		# Update new list
		nets[new_net].extend(nets[old_net])

		# Delete old net
		del nets[old_net]


	def connect_polygons(self, pl, nets):

		# Scan looking for intersections
		for i in range(len(pl)):
			# Grab infos
			p1 = pl[i]

			# Is the poly in a net already ?
			if p1.net is None:
				# Assign a new net
				p1.net = self.net_id_nxt
				self.net_id_nxt += 1
				nets[p1.net] = [ p1 ]

			# Scan all the other boxes for potential matches
			for j in range(i+1, len(pl)):
				# Grab infos
				p2 = pl[j]

				# Already belong to the same net ?
				if p1.net == p2.net:
					continue

				# If we're too far already, no need to keep scanning
				if p2.bbox.x0 > p1.bbox.x1:
					break

				# Check if the poly intersect
				if not p1.intersect(p2):
					continue

				# We have a connection, merge groups
				if p2.net is None:
					# p2 isn't in any net, just add to the same as p1
					p2.net = p1.net
					nets[p1.net].append(p2)

				else:
					# p2 is already in a net, merge the two
					self.merge_nets(nets, p1.net, p2.net)

		return nets


	def connect_vias(self, pl_met, pl_via, nets):

		# Scan through all the polygons
		v_idx_start = 0

		for i in range(len(pl_met)):

			# Get entry
			p_met = pl_met[i]

			# Scan through all the vias
			for j in range(v_idx_start, len(pl_via)):

				# Get entry
				p_via = pl_via[j]

				# If already in the same net, skip
				if p_met.net == p_via.net:
					continue

				# If we're too "early", we can advance the start index
				# Vias are small squares of all same sizes
				if p_via.bbox.x1 < p_met.bbox.x0:
					v_idx_start = j
					continue

				# If we're too far already, no need to keep scanning
				if p_via.bbox.x0 > p_met.bbox.x1:
					break

				# Check if the poly intersect
				if not p_via.intersect(p_met):
					continue

				# Got a hit !
				if p_via.net is None:
					# Via isn't in any net, just add to the same as metal
					p_via.net = p_met.net
					nets[p_met.net].append(p_via)

				else:
					# Via is already is a net, we need to merge nets
					self.merge_nets(nets, p_met.net, p_via.net)

				# If we're the first via in list, we can advance
				if v_idx_start == j:
					v_idx_start = j + 1


	def gds_load(self, gds_filename):
		self.lib = gdstk.read_gds(gds_filename)
		self.top = self.lib.top_level()[0]


	def process(self):
		eprint("[+] Preprocessing geometry")
		self.flatten_via(self.top)
		self.simplify_subcells(self.top)

		eprint("[+] Extracting polygons")
		self.collect_metal_polygons()
		self.collect_via_polygons()

		eprint("[+] Processing nets for each metal layer")
		self.nets = {}
		for ly_num in LAYER_STACK[0::2]:
			lnets = {}
			self.connect_polygons(self.ly_polys[ly_num], lnets)
			eprint(f"[-] Extracted layer {ly_num:3d} : {len(self.ly_polys[ly_num]):5d} polygons -> {len(lnets):5d}  nets")
			self.nets.update(lnets)

		eprint("[+] Processing via connections between metal layers")
		for i in range(1,len(LAYER_STACK),2):
			# Layer IDs
			bot = LAYER_STACK[i-1]
			via = LAYER_STACK[i]
			top = LAYER_STACK[i+1]

			eprint(f"[-] {bot:3d} -- {via:3d} -- {top:3d}")

			# Connect nets as needed
			self.connect_vias(self.ly_polys[bot], self.ly_polys[via], self.nets)
			self.connect_vias(self.ly_polys[top], self.ly_polys[via], self.nets)


	def implicit_pin_connect(self, name_re):
		# Scan all pads
		for ((pad_ref, pad_name), pl) in self.pads.items():
			# Only consider pad with multiple geometry
			if len(pl) <= 1:
				continue

			# No top level
			if pad_ref is None:
				continue

			# Matching regular expression ?
			if not re.match(name_re, pad_ref.cell.name):
				continue

			# Collect net
			while True:
				# Check current list of ids
				nl = { p.net for p in pl }
				if len(nl) == 1:
					break

				# Merge two
				self.merge_nets(self.nets, nl.pop(), nl.pop())


	def check_multi_pads(self):
		ok = True
		for k,v in self.pads.items():
			if len({x.net for x in v}) != 1:
				eprint(f"[!] Pad {k[1]} on cell {k[0].cell.name} at {k[0].origin} not fully connected")
				ok = False
		return ok


	def write_debug_gds(self, filename):
		# Create new library
		dbg_lib = gdstk.Library()

		# Add top cell and dependencies
		dbg_lib.add(self.top)
		for sc in self.top.dependencies(recursive=True):
			dbg_lib.add(sc)

		# Add flattened references
		for r in self.top.references:
			dbg_lib.add( self.reference_flatten(r) )

		# Add all nets
		for n, pl in self.nets.items():
			c = gdstk.Cell('net_' + str(n))
			for p in pl:
				c.add(p.gp.copy())
			dbg_lib.add(c)

		# Write out GDS
		dbg_lib.write_gds(filename)

	def _split_lines(self, lines):
		ln = []
		for l in lines:
			# Short lines
			if len(l) < 80:
				ln.append(l)
				continue

			# Long line
			t = l.split(' ')
			i = 1
			l = t[0]

			while i < len(t):
				if (len(l) + len(t[i])) < 80:
					l = l + ' ' + t[i]
				else:
					ln.append(l)
					l = '+ ' + t[i]
				i = i + 1

			ln.append(l)

		return ln

	def write_spice(self, filename):
		# Default
		lines = []

		# Create sorted pad list for top and each sub-cell type
		pl = {}

		for ref, pad_name in self.pads.keys():
			k = ref.cell.name if ref is not None else None
			pl.setdefault(k, set()).add(pad_name)

		pl = { k: num_sort(v)  for k,v in pl.items() }

		# Process all sub cells to create empty stub
		for k, v in pl.items():
			# Skip top-cell
			if k is None:
				continue

			cell_name = k[:-3]
			arg_lst = ' '.join(v)
			lines.append(f".subckt {cell_name} {arg_lst}")
			lines.append(".ends")

		# Header for top cell
		cell_name = self.top.name
		arg_lst = ' '.join(pl[None])

		lines.append(f".subckt {cell_name} {arg_lst}")

		# Use 0R to connect pads to internal net names
		for i,n in enumerate(pl[None]):
			if self.pads[(None, n)]:
				lines.append(f"R{i} {n} net_{self.pads[(None,n)][0].net} 0")

		# Create all sub-cell instances
		for i,ref in enumerate(self.top.references):
			args_conn = ' '.join([f'net_{self.pads[(ref,n)][0].net}' for n in pl[ref.cell.name]])
			lines.append(f"X{i} {args_conn} {ref.cell.name[:-3]}")

		# Footer for top cell
		lines.append(".ends")

		# Write outuput
		with open(filename, 'w') as fh:
			fh.write('\n'.join(self._split_lines(lines)))

		return


def hack_bondpad(c):
	# Flatten
	c.flatten()

	# Copy all TopMetal2 polygon to the PIN layer and add property
	# for pin name
	for p in c.get_polygons(layer=134, datatype=DWG_DT):
		p.set_gds_property(1, 'pad')
		p = p.copy()
		p.datatype=PIN_DT
		c.add(p)



def main(argv0, gds_filename, spice_filename, dbg_gds_filename=None):

	# Load the GDS
	ex = NetlistExtractor()
	ex.gds_load(gds_filename)

	# Hack the bondpad to add an exported pin
	hack_bondpad(ex.lib['bondpad_70x70'])

	# Run the extraction process
	ex.process()

	# Post-fixups : All the IO ring cells have implicitely connected pads
	ex.implicit_pin_connect("^sg13g2_IO.*")
	ex.implicit_pin_connect("^sg13g2_Corner.*")

	# Checks pads
	if not ex.check_multi_pads():
		return -1

	# Complete the 'pad_raw' top list
	for i in range(64):
		n = f'pad_raw[{i}]'
		if (None, n) not in ex.pads:
			ex.pads[(None,n)] = []

	# Debug output
	if dbg_gds_filename is not None:
		ex.write_debug_gds(dbg_gds_filename)

	# Write output SPICE
	ex.write_spice(spice_filename)

	return 0


if __name__ == '__main__':
	sys.exit(main(*sys.argv))

