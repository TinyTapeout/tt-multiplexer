#!/usr/bin/env python3

#
# Parse SPEF file looking for a particular net and extracts
# a SPICE model and DOT graph for that particular net
#
# Copyright (c) 2023 Sylvain Munaut <tnt@246tNt.com>
# SPDX-License-Identifier: Apache-2.0
#

import argparse


class SPEFNetParser:

	def __init__(self, spef_fh):
		# Empty data
		self.data     = {}

		self.nodes    = {}
		self.vertices = {}

		self._n_port  = 0
		self._n_int   = 0

		# Open source file
		self.fh = spef_fh

	def find_net(self, net_name):
		# Scan file for name map
		in_name = False
		net_id = None

		for l in self.fh:
			# Strip
			l = l.strip()

			# Are we in name ?
			if in_name:
				# End ?
				if l == '':
					break

				# Save name if it's IO
				n_id, n_name = l.split()
				if n_name == net_name:
					net_id = int(n_id[1:])

			# If not, wait for it
			elif l == '*NAME_MAP':
				in_name = True

		return net_id

	def parse_net(self, net_num):
		# Initial state
		section = None

		# Scan all lines
		for l in self.fh:
			# Strip
			l = l.strip()

			# If not found net, only look for it
			if section is None:
				if l.startswith(f'*D_NET *{net_num:d} '):
					section = True
			else:
				# Done ?
				if l == '*END':
					return True

				# New section ?
				if l in ['*CONN', '*CAP', '*RES']:
					section = l[1:]
					continue

				# Append line
				self.data.setdefault(section, []).append(l)

		return False

	def _get_node(self, spef_name, is_port=False):
		# Try fetch first
		node = self.nodes.get(spef_name)

		# Create if needed
		if node is None:
			# New name
			if is_port:
				spice_name = f'p{self._n_port:d}'
				self._n_port  += 1
			else:
				spice_name = f'n{self._n_int:d}'
				self._n_int   += 1

			# Add
			self.nodes[spef_name] = node = {
				'spice_name' : spice_name,
				'spef_name'  : spef_name,
				'cap'        : 0.0,
			}

		# Return
		return node

	def analyze_net(self):
		# Create nodes for ports
		for e in self.data['CONN']:
			typ, name, io, unk, inst = e.split()
			self._get_node(name, is_port=True)

		# Collect resistances
		for e in self.data['RES']:
			# Split
			idx, n1, n2, res = e.split()

			# Add link
			n1s = min(n1,n2)
			n2s = max(n1,n2)

			self.vertices[(n1s, n2s)] = float(res)

			# Create nodes
			self._get_node(name)

		# Collect capacitance
		for e in self.data['CAP']:
			# Split
			v = e.split()

			if len(v) == 3:
				# Direct capacitance
				idx, spef_name, cap = v
			elif len(v) == 4:
				# Mutual capacitance modelled as cap to ground
				idx, spef_name1, spef_name2, cap = v

				if spef_name1 in self.nodes:
					spef_name = spef_name1

				if spef_name2 in self.nodes:
					spef_name = spef_name2
			else:
				raise RuntimeError('Invalid cap format')

			# Add capacitance to node
			self._get_node(spef_name)['cap'] += float(cap)

	def write_spice(self, spice_fh):
		# Init
		lines = []

		# Output a comment for each 'port' node
		lines.append('* Port nodes mapping')
		for n in self.nodes.values():
			if n['spice_name'][0] == 'p':
				lines.append(f"*   {n['spice_name']:4s} -> {n['spef_name']:s}")
		lines.append('')

		# Output all capacitance for each node
		lines.append('* Node capacitances')
		for n in self.nodes.values():
			if n['cap'] > 0:
				lines.append(f"C_{n['spice_name']:s} {n['spice_name']:s} 0 {n['cap']:f}p")
		lines.append('')

		# Output resistor for each vertex
		lines.append('* Inter-Node resistances')
		for (nn1, nn2), res in self.vertices.items():
			# Grab nodes
			n1 = self.nodes[nn1]
			n2 = self.nodes[nn2]

			# Write line
			lines.append(f"R_{n1['spice_name']:s}_{n2['spice_name']:s} {n1['spice_name']:s} {n2['spice_name']:s} {res:f}")

		# Write to file
		spice_fh.write('\n'.join(lines))

	def write_dot(self, dot_fh):
		# Init
		lines = [
			'graph D {',
			'graph [layout="neato"]',
		]

		# Output each nodes
		for n in self.nodes.values():
			lines.append(f"{n['spice_name']:s} [label=<<b>{n['spice_name']:s}</b><br/>{1e3*n['cap']:.1f}f>, shape={'ellipse' if n['spice_name'][0]=='p' else 'box':s}]")

		# Output each vertex
		for (nn1, nn2), res in self.vertices.items():
			# Grab nodes
			n1 = self.nodes[nn1]
			n2 = self.nodes[nn2]

			# Write line
			lines.append(f"{n1['spice_name']:s} -- {n2['spice_name']:s} [label=\"{res:.2f}\"]")

		# end
		lines.append('}')

		# Write to file
		dot_fh.write('\n'.join(lines))


def main():
	# Arguments
	parser = argparse.ArgumentParser()

	parser.add_argument(
		'--spef', '-i', help='Input SPEF file',
		type=argparse.FileType('r'), required=True,
	)
	parser.add_argument(
		'--spice', '-o', help='Output SPICE file',
		type=argparse.FileType('w'),
	)
	parser.add_argument(
		'--dot', '-d', help='Output DOT file',
		type=argparse.FileType('w'),
	)

	group = parser.add_mutually_exclusive_group(required=True)
	group.add_argument(
		'--net-id', '-n', help='Select net by ID number',
		type=int
	)
	group.add_argument(
		'--net-name', '-N', help='Select net by name',
		type=str
	)

	args = parser.parse_args()

	# Do the SPEF parsing
	spef = SPEFNetParser(args.spef)

	if args.net_name is not None:
		# Find net
		net_id = spef.find_net(args.net_name)
		if net_id is None:
			print("Net name not found")
			return

	elif args.net_id is not None:
		net_id = args.net_id

	if not spef.parse_net(net_id):
		print("Net not found")
		return

	spef.analyze_net()

	# Outputs
	if args.spice is not None:
		spef.write_spice(args.spice)

	if args.dot is not None:
		spef.write_dot(args.dot)


if __name__ == '__main__':
	main()

