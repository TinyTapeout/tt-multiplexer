#!/usr/bin/env python3

import sys


def gen_hdr(pads):
	# Remove pad_raw
	pads = [ p for p in pads if not p.startswith('pad_raw[') ]

	# Sort by length
	pads = sorted(pads, key=lambda x: len(x))

	# Add full list of pad_raw
	pads.extend([f'pad_raw[{i}]' for i in range(74)])

	# Output
	l = [ '.subckt', 'tt_gf_wrapper' ]
	l.extend(pads)

	r = []
	cl = []

	for t in l:
		if (len(cl) + sum([len(x) for x in cl]) + len(t)) > 75:
			r.append(' '.join(cl) + '\n')
			cl = ['+']
		cl.append(t)

	if cl:
		r.append(' '.join(cl) + '\n')

	return ''.join(r)


def main(argv0, in_spice, out_spice):

	pads = None

	with open(in_spice, 'r') as fh_in, open(out_spice, 'w') as fh_out:
		for line in fh_in:
			if pads is not None:
				if line[0] == '+':
					# Collect pads
					pads.extend(line.strip().split()[1:])

				else:
					# Output new header
					fh_out.write(gen_hdr(pads))

					# End header mode
					pads = None

					# Output this line
					fh_out.write(line)

			elif line.startswith('.subckt tt_gf_wrapper'):
				# Collect pads
				pads = line.strip().split()[2:]

			else:
				# Normal line, just copy
				fh_out.write(line)


if __name__ == '__main__':
	main(*sys.argv)
