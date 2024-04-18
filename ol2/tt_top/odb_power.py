#
# OpenDB script for custom Power for tt_top / user_project_wrapper
#
# Copyright (c) 2023 Sylvain Munaut <tnt@246tNt.com>
# SPDX-License-Identifier: Apache-2.0
#

import os
import sys
import yaml

import odb

sys.path.append('../../py')
import tt
import tt_odb

import click

from reader import click_odb


@click.command()
@click_odb
def power(
	reader,
):

	# Load TinyTapeout
	tti = tt.TinyTapeout(modules=False)

	# Create ground / power nets
	net_gnd = reader.block.findNet('vssd1')
	if net_gnd is None:
		net_gnd = odb.dbNet.create(reader.block, 'vssd1')
	net_gnd.setSpecial()
	net_gnd.setSigType('GROUND')

	net_pwr = reader.block.findNet('vccd1')
	if net_pwr is None:
		net_pwr = odb.dbNet.create(reader.block, 'vccd1')
	net_pwr.setSpecial()
	net_pwr.setSigType('POWER')

	# Scan all blocks
	for blk_inst in reader.block.getInsts():
		# Defaults
		vgnd = net_gnd
		vpwr = net_pwr

		# Is it a user block ?
		if blk_inst.getName().endswith('tt_um_I'):
			# Try to find a matching power switch
			pg_name = '.'.join(blk_inst.getName().split('.')[:-1] + ['tt_pg_vdd_I'])
			pg_inst = reader.block.findInst(pg_name)

			# If there is one, we have some wiring to do
			if pg_inst is not None:
				# Create switched power net
				vpwr_name = '.'.join(blk_inst.getName().split('.')[:-1] + ['vpwr'])
				vpwr = odb.dbNet.create(reader.block, vpwr_name)
				vpwr.setSpecial()
				vpwr.setSigType('POWER')

				# Connect it to the PG output
				pg_inst.findITerm('GPWR').connect(vpwr)

		# Wire up power/ground to the selected nets
		blk_inst.findITerm('VGND').connect(vgnd)
		blk_inst.findITerm('VPWR').connect(vpwr)


if __name__ == "__main__":
	power()
