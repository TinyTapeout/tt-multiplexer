#!/usr/bin/env python3

#
# Utilities to write OpenDB scripts for TT
#
# Copyright (c) 2023 Sylvain Munaut <tnt@246tNt.com>
# SPDX-License-Identifier: Apache-2.0
#

import odb


def place_pin(die_area, layer, bterm, pos, side='N', wide=False):
	# Get limits
	BLOCK_LL_X = die_area.xMin()
	BLOCK_LL_Y = die_area.yMin()
	BLOCK_UR_X = die_area.xMax()
	BLOCK_UR_Y = die_area.yMax()

	# Create pin
	bpin = odb.dbBPin_create(bterm)
	bpin.setPlacementStatus("PLACED")

	# Rectangle graphic
	WIDTH  = 300
	LENGTH = 1000

	if wide:
		WIDTH *= 3

	if side == 'N':
		rect = odb.Rect(0, 0, WIDTH, LENGTH)
		rect.moveTo(pos - WIDTH // 2, BLOCK_UR_Y - LENGTH)

	elif side == 'S':
		rect = odb.Rect(0, 0, WIDTH, LENGTH)
		rect.moveTo(pos - WIDTH // 2, BLOCK_LL_Y)

	elif side == 'W':
		rect = odb.Rect(0, 0, LENGTH, WIDTH)
		rect.moveTo(BLOCK_LL_X, pos - WIDTH // 2)

	elif side == 'E':
		rect = odb.Rect(0, 0, LENGTH, WIDTH)
		rect.moveTo(BLOCK_UR_X - LENGTH, pos - WIDTH // 2)

	elif side == 'V':
		rect = odb.Rect(0, 0, WIDTH, BLOCK_UR_Y - BLOCK_LL_Y)
		rect.moveTo(pos - WIDTH // 2, BLOCK_LL_Y)

	elif side == 'H':
		rect = odb.Rect(0, 0, BLOCK_UR_X - BLOCK_LL_X, WIDTH)
		rect.moveTo(BLOCK_LL_X, pos - WIDTH // 2)

	else:
		raise RuntimeError('Invalid pin position')

	# Add to OpenDB
	odb.dbBox_create(bpin, layer, *rect.ll(), *rect.ur())
