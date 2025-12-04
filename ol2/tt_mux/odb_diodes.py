#
# OpenDB script for custom Diodes placement
#
# Copyright (c) 2023 Sylvain Munaut <tnt@246tNt.com>
# SPDX-License-Identifier: Apache-2.0
#

import click

import sys
sys.path.append('/nix/store/3mgw36fzvz3f3f0wbqvr7w3dzp4pck5n-devshell-dir/lib/python3.12/site-packages/')
sys.path.append('/mnt/pdk/OL2/librelane/librelane/scripts/odbpy')

from reader import click_odb



@click.command()
@click_odb
def diodes_place(
	reader,
):

	# FIXME: Better way to identify diodes
	diodes = [x for x in reader.block.getInsts() if 'antenna' in x.getMaster().getName()]

	# Process each diode
	for diode in diodes:
		# Find antenna ITerm and associated net
		it_lst = [it for it in diode.getITerms() if it.getSigType() == 'SIGNAL']
		if len(it_lst) != 1:
			raise RuntimeError('Diode with more than 1 signal ITerm !')

		it_diode = it_lst[0]
		net = it_diode.getNet()

		# Default position
		pos_x = 0
		pos_y = 0
		pos_w = 0

		# Add BTerms
		for bt in net.getBTerms():
			v, x, y = bt.getFirstPinLocation()
			if v:
				w = 1
				pos_x += x * w
				pos_y += y * w
				pos_w += w

		# Add ITerms
		for it in net.getITerms():
			if it.getName() == it_diode.getName():
				continue

			inst = it.getInst()
			if inst.getPlacementStatus() != 'PLACED':
				continue
			
			x, y = inst.getOrigin()

			w = 4
			pos_x += x * w
			pos_y += y * w
			pos_w += w

		# Position
		pos_x //= pos_w
		pos_y //= pos_w

		diode.setOrigin(pos_x, pos_y)

#	import IPython
#	IPython.embed()

	return
	



if __name__ == "__main__":
	diodes_place()
