#!/usr/bin/env python3

import re
import sys


POWER_NAMES = { 'VGND', 'VDPWR', 'VPWR' }


def process_lef(lef_in_fn, lef_out_fn):
	# Read input
	lines_in = open(lef_in_fn, 'r').readlines()

	# Parse and modify
	lines_out = []

	in_pin = None
	for l in lines_in:
		# Strip
		l = l.rstrip()

		# Process
		if in_pin is None:
			# Check for start of pin
			m = re.match(r'\s*PIN\s+(\w+)\s*$', l)
			if (m is not None) and (m.group(1) in POWER_NAMES):
				in_pin = m.group(1)

		else:
			# Check for the end
			m = re.match(r'\s*END\s+(\w+)\s*$', l)
			if (m is not None) and (m.group(1) == in_pin):
				in_pin = None

			# Replace any 'Metal5'
			l = re.sub(r'LAYER\s+Metal5\s+;', 'LAYER TopMetal1 ;', l)

		# Append
		lines_out.append(l)
			

	# Save ouptut
	open(lef_out_fn, 'w').write('\n'.join(lines_out))


if __name__ == '__main__':
	process_lef(sys.argv[1], sys.argv[2])	

