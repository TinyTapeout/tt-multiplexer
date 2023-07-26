#!/usr/bin/env python3

#
# Parse SPEF file looking for nets matching a regexp
# and extract their total capacitance
#
# Copyright (c) 2023 Sylvain Munaut <tnt@246tNt.com>
# SPDX-License-Identifier: Apache-2.0
#

import argparse
import re


class SPEFParser:

	def __init__(self, spef_fh, net_re):
		# Save params
		self.fh = spef_fh
		self.net_re = net_re

		# Data
		self.nets = {}

	def parse(self):
		# Initial state
		in_name = False

		# Scan all lines
		for l in self.fh:
			# Strip
			l = l.strip()

			# Are we in name ?
			if in_name:
				# End ?
				if l == '':
					in_name = False
					continue

				# Split values
				n_id, n_name = l.split()

				# If it matches, save it
				m = self.net_re.match(n_name)
				if m is None:
					continue

				grp = m.group(1) if self.net_re.groups > 0 else None
				self.nets[n_id] = (grp, n_name, None)

			# If not, maybe start it ?
			elif l == '*NAME_MAP':
				in_name = True

 			# Or a D_NET ?
			elif l.startswith('*D_NET'):
				cmd, n_id, n_cap = l.split()
				net = self.nets.get(n_id)
				if net is not None:
					net = ( net[0], net[1], float(n_cap) )
					self.nets[n_id] = net

	def results(self):
		# Classify by groups
		caps = {}
		for n_grp, n_name, n_cap in self.nets.values():
			if n_cap is None:
				continue
			caps.setdefault(n_grp, []).append(n_cap)

		# Iterate groups
		for grp, lst in caps.items():
			# Stats
			v_min = min(lst)
			v_max = max(lst)
			v_avg = sum(lst) / len(lst)

			# Result
			print(f'{grp or "":20s} Min:{1e3*v_min:8.2f}f\tAvg:{1e3*v_avg:8.2f}f\tMax:{1e3*v_max:8.2f}f\tN:{len(lst):4d}')


def main():
	# Arguments
	parser = argparse.ArgumentParser()

	parser.add_argument(
		'--spef', '-i', help='Input SPEF file',
		type=argparse.FileType('r'), required=True,
	)
	parser.add_argument(
        '--net', '-n', help='Regexp to match net against',
		type=str
	)

	args = parser.parse_args()

	# Validate and compite regexp
	net_re = re.compile(args.net)

	# Do the SPEF parsing and show results
	spef = SPEFParser(args.spef, net_re)
	spef.parse()
	spef.results()


if __name__ == '__main__':
	main()

