#!/usr/bin/env python3

import sys
import gdstk


LY_METAL5    =  67
LY_TOPVIA1   = 125
LY_TOPMETAL1 = 126

DT_DWG  =  0
DT_PIN  =  2
DT_TEXT = 25

POWER_NAMES = { 'VGND', 'VDPWR', 'VPWR' }

CUT_WIDTH = 0.42
CUT_SPACE = 0.42


def process_pin(cell, pin, label, net_name):
	# Get bounding box
	bbox = pin.bounding_box()

	b_width  = bbox[1][0] - bbox[0][0]
	b_height = bbox[1][1] - bbox[0][1]

	# If with is less than 2.1u that's a problem
	if (bbox[1][0] - bbox[0][0]) < 2.1:
		raise RuntimeError('Power rail not wide enough')

	# Copy the pin to TopMetal1
	p_pin = pin.copy()
	p_pin.layer = LY_TOPMETAL1
	cell.add(p_pin)

	# Create a copy in TopMetal1 drawing and add label
	p_dwg = pin.copy()
	p_dwg.layer = LY_TOPMETAL1
	p_dwg.datatype = DT_DWG
	cell.add(p_dwg)

	l = label.copy()
	l.layer = LY_TOPMETAL1
	cell.add(l)

	# Generate the cuts
	n_x = int((b_width - CUT_SPACE ) // (CUT_WIDTH + CUT_SPACE))
	n_y = int((b_height - CUT_SPACE) // (CUT_WIDTH + CUT_SPACE))

	ofs_x = (b_width  + CUT_SPACE - n_x * (CUT_WIDTH + CUT_SPACE)) / 2
	ofs_y = (b_height + CUT_SPACE - n_y * (CUT_WIDTH + CUT_SPACE)) / 2

	ofs_x = round(ofs_x * 200) / 200
	ofs_y = round(ofs_y * 200) / 200

	x0 = bbox[0][0] + ofs_x
	y0 = bbox[0][1] + ofs_y
	x1 = x0 + CUT_WIDTH
	y1 = y0 + CUT_WIDTH

	cuts = gdstk.Polygon([(x0,y0), (x1, y0), (x1, y1), (x0, y1)], layer=LY_TOPVIA1, datatype=DT_DWG)
	cuts.repetition = gdstk.Repetition(
		columns = n_x,
		rows    = n_y,
		spacing = (
			CUT_WIDTH + CUT_SPACE,
			CUT_WIDTH + CUT_SPACE
		)
	)

	cell.add(cuts)


def process_gds(gds_in_fn, gds_out_fn):

	# Load input
	is_oas = gds_in_fn.endswith('.oas')
	lib = gdstk.read_gds(gds_in_fn) if not is_oas else gdstk.read_oas(gds_in_fn)
	top_cells = lib.top_level()
	if len(top_cells) != 1:
		raise RuntimeError('More than one top-cell')

	top = top_cells[0]

	# Find all labels
	labels = [l for l in top.get_labels(layer=LY_METAL5) if l.text in POWER_NAMES]

	# Find all matching pins
	power_pins = []

	for p in top.get_polygons(layer=LY_METAL5, datatype=DT_PIN):
		for l in labels:
			if p.contain(l.origin):
				power_pins.append( (p, l, l.text) )
				break

	# Process each pin
	for pin, label, net_name in power_pins:
		process_pin(top, pin, label, net_name)

	# Delete pins
	# (don't use get_polygons so we get the raw polygons which may have Repetition)
	for p in list(top.polygons):
		if (p.layer != LY_METAL5) or (p.datatype != DT_PIN):
			continue
		for l in labels:
			if p.contain(l.origin):
				print("x")
				top.remove(p)
				break

	# Save result
	if is_oas:
		lib.write_oas(gds_out_fn)
	else:
		lib.write_gds(gds_out_fn)


if __name__ == '__main__':
	process_gds(sys.argv[1], sys.argv[2])	

