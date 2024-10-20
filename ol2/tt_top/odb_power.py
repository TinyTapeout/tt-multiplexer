#
# OpenDB script for custom Power for tt_top / user_project_wrapper
#
# Copyright (c) 2023 Sylvain Munaut <tnt@246tNt.com>
# SPDX-License-Identifier: Apache-2.0
#

import os
import re
import sys
import yaml

import odb

sys.path.append('../../py')
import tt
import tt_odb

import click

try:
	from reader import click_odb
	interactive = False
except:
	sys.path.insert(0, os.path.join("/mnt/pdk/OL2/openlane2/openlane", "scripts", "odbpy"))
	interactive = True
	from reader import click_odb



@click.command()
@click_odb
def power(
	reader,
):

	# Config
	PDN = {
		'vgnd' : {
			'type' :  'GROUND',
			'pins' : [ 'VGND', 'vss' ],
		},
		'vdpwr' : {
			'type' : 'POWER',
			'pins' : [ 'VPWR', 'VDPWR', 'vdd' ],
			'pg' : ( 'tt_pg_vdd_I', 'VPWR', 'GPWR' ),
		},
		'vapwr' : {
			'type' : 'POWER',
			'pins' : [ 'VAPWR' ],
			'pg' : ( 'tt_pg_vaa_I', 'VAPWR', 'GAPWR' ),
		},
		'iovss' : {
			'type' : 'GROUND',
			'pins' : [ 'iovss' ],
		},
		'iovdd' : {
			'type' : 'POWER',
			'pins' : [ 'iovdd' ],
		},
	}

	# Load TinyTapeout
	tti = tt.TinyTapeout(modules=False)

	# Create ground / power nets
	pin2net = {}
	pgs = {}

	for net_name, net_desc in PDN.items():
		net = reader.block.findNet(net_name)
		if net is None:
			# Create net
			net = odb.dbNet.create(reader.block, net_name)
			net.setSpecial()
			net.setSigType(net_desc['type'])

		# Record data
		for pin_name in net_desc['pins']:
			pin2net[pin_name] = (net, net_desc)

		if 'pg' in net_desc:
			pgs[net_desc['pg'][0]] = net_desc['pg'][1:]

	# Scan all blocks
	for blk_inst in reader.block.getInsts():
		# Check if it's a power gate ?
		is_pg = re.match(r'.*\.tt_pg_[\w_]*_I$', blk_inst.getName()) is not None

		# Check if it's a user block
		is_um = blk_inst.getName().endswith('.tt_um_I')

		# Scan all ITerms
		for iterm in blk_inst.getITerms():
			# If it's not a known power one, skip
			pin_name = iterm.getMTerm().getName()
			if pin_name not in pin2net:
				continue

			# Get data
			net, net_desc = pin2net[pin_name]
			net_name = net.getName()

			# If we're a power gate and this is one of the switched net,
			# skip it, those will be handled when wiring the corresponding block
			if is_pg:
				pg_name = blk_inst.getName().split('.')[-1]
				pg_desc = pgs[pg_name]
				if pin_name in pg_desc:
					continue

			# If we're user block, does net have a potential power gate ?
			if is_um and ('pg' in net_desc):
				# Get power gate description
				pg_desc = net_desc['pg']

				# Build full name and look for it
				pg_name = '.'.join(blk_inst.getName().split('.')[:-1] + [pg_desc[0]])
				pg_inst = reader.block.findInst(pg_name)

				# If there is one, we have some wiring to do
				if pg_inst is not None:
					# Connect source power to PG input
					pg_inst.findITerm(pg_desc[1]).connect(net)

					# Create switched power net
					vpwr_name = '.'.join(blk_inst.getName().split('.')[:-1] + [net_name])
					vpwr = odb.dbNet.create(reader.block, vpwr_name)
					vpwr.setSpecial()
					vpwr.setSigType(net_desc['type'])

					# Connect it to the PG output
					pg_inst.findITerm(pg_desc[2]).connect(vpwr)

					# And use that instead
					net = vpwr

			# Connect
			iterm.connect(net)


if __name__ == "__main__":
	power()
