#!/usr/bin/env python3

import gdstk


lib_main = gdstk.read_gds('filled.gds')
lib_fill = gdstk.read_gds('filled_simplified.gds')

top_main = lib_main.top_level()[0]
top_fill = lib_fill.top_level()[0]


c = set()
for r in top_fill.references:
	if r.cell_name.endswith('_FILL_CELL'):
		if r.cell_name not in c:
			lib_main.add(r.cell)
			c.add(r.cell_name)
		top_main.add(r)

to_rem = []

for r in top_main.references:
	if r.cell_name != 'Met3S_FILL_CELL':
		continue
	
	if (not (int(r.origin[0] * 1000) % 5) and not (int(r.origin[1] * 1000) % 5)):
		continue
	
	if (r.origin[0] < 300) or (r.origin[1] < 300) or (r.origin[0] > 3300) or (r.origin[1] > 4700):
		to_rem.append(r)
		continue

	ox = (int(r.origin[0] * 1000) // 5) * 0.005
	oy = (int(r.origin[1] * 1000) // 5) * 0.005

	r.origin = ( ox, oy )

for r in to_rem:
	top_main.remove(r)

lib_main.write_gds('tt_ihp_wrapper_3f7e017c47c39938c18e7a5cdab3393b793a6699_filled.gds')

