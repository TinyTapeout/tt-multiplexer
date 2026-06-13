#
# OpenDB script to cleanup the database from spurious BTerms
#
# Copyright (c) 2023 Sylvain Munaut <tnt@246tNt.com>
# SPDX-License-Identifier: Apache-2.0
#

import odb
import click

from reader import click_odb


def getOtherITermsOnNet(it):
	return [x for x in it.getNet().getITerms() if x.this != it.this]


@click.command()
@click_odb
def route(
	reader,
):

	# Scan all blocks
	for ckt in reader.block.getInsts():
		# Only interested in analog contacts
		if ckt.getMaster().getName() != 'tt_ckt_ana':
			continue

		# Scan ITerms
		for it in ckt.getITerms():
			# Get net
			net = it.getNet()

			# Only interested in ITerm that connect to BTerm
			if not net.getBTerms():
				continue

			# Find ITerm from IO Pad
			it_io = getOtherITermsOnNet(it)[0]
			pad = it_io.getInst()

			# We need the same orientation
			ckt.setOrient( pad.getOrient() )

			# Position is more tricky
			org_x, org_y = pad.getOrigin()

			if pad.getOrient() == 'R0':
				org_y += pad.getMaster().getHeight()

			elif pad.getOrient() == 'R90':
				org_x -= pad.getMaster().getHeight()

			elif pad.getOrient() == 'MX':
				org_y -= pad.getMaster().getHeight()

			elif pad.getOrient() == 'MXR90':
				org_x += pad.getMaster().getHeight()

			else:
				raise RuntimeError('Unsupported IO orientation')

			ckt.setOrigin(org_x, org_y)

			# Done
			ckt.setPlacementStatus('FIRM')


if __name__ == "__main__":
	route()
