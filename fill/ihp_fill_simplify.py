#!/usr/bin/env python3

import gdstk


LY = [
	( 1, 0 ),
	( 8, 0 ),
]

l = gdstk.read_gds('tt_ihp_wrapper_3f7e017c47c39938c18e7a5cdab3393b793a6699.gds')

top = l.top_level()[0]


def simplify_cell(cell):
	# Get boundary
	bbox = cell.get_polygons(layer=235, datatype=4)[0].bounding_box()

	# Create a new cell
	new_cell = gdstk.Cell(cell.name + '_bb')

	# Add fill layers
	c1 = ( bbox[0][0] + 2.0, bbox[0][1] + 2.0 )
	c2 = ( bbox[1][0] - 2.0, bbox[1][1] - 2.0 )

	for ly,dt in LY:
		new_cell.add( gdstk.rectangle(c1,c2, layer=ly, datatype=dt) )

	return new_cell

def simplify_subcells(cell):
	sc = {}
	for r in cell.references:
		if not r.cell_name.startswith('tt_'):
			continue
		if r.cell_name not in sc:
			sc[r.cell_name] = simplify_cell(r.cell)
		r.cell = sc[r.cell_name]

simplify_subcells(top)

out_lib = gdstk.Library()

out_lib.add(top)
for sc in top.dependencies(recursive=True):
	out_lib.add(sc)

out_lib.write_gds('tt_ihp_wrapper_3f7e017c47c39938c18e7a5cdab3393b793a6699_simplified.gds')

