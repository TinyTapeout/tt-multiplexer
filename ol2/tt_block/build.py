#!/usr/bin/env python3

#
# OpenLane2 build script to generate all TT blocks templates
#
# Copyright (c) 2023 Sylvain Munaut <tnt@246tNt.com>
# SPDX-License-Identifier: Apache-2.0
#

import glob
import os
import shutil
import sys

from typing import List, Type

from openlane.flows.sequential import SequentialFlow
from openlane.steps.odb import OdbpyStep
from openlane.steps import (
	Step,
	Yosys,
	OpenROAD,
	Misc,
)

sys.path.append('../../py')
import tt


class IOPlacement(OdbpyStep):

	id = "TT.Block.IOPlacement"
	name = "Custom IO placement for TT User Blocks"

	def get_script_path(self):
		return os.path.join(
			os.path.dirname(__file__),
			"odb_ioplace.py"
		)


class BlockTemplateFlow(SequentialFlow):

	Steps: List[Type[Step]] = [
		Yosys.Synthesis,
		Misc.LoadBaseSDC,
		OpenROAD.Floorplan,
		IOPlacement,
	]


def gen_block_template(tti, h_mult, v_mult, pg_vdd=False, pg_vaa=False, analog=False):
	# Get PDK root out of environment
	PDK_ROOT = os.getenv('PDK_ROOT')

	# Create directory
	design_dir = f"{h_mult:d}x{v_mult:d}{'_pgvdd' if pg_vdd else ''}{'_pgvaa' if pg_vaa else ''}{'_ana' if analog else ''}"
	if not os.path.exists(design_dir):
		os.mkdir(design_dir)

	# Final block width and height
	block_width  = (
		 h_mult      * tti.layout.glb.block.width +
		(h_mult - 1) * tti.layout.glb.margin.x
	)

	block_height = (
		 v_mult      * tti.layout.glb.block.height +
		(v_mult - 1) * tti.layout.glb.margin.y
	)

	# If we're power gated the block width is reduced
	if pg_vdd:
		block_width -= tti.layout.glb.pg_vdd.offset

	if pg_vaa:
		block_width -= tti.layout.glb.pg_vaa.offset

	# Options
	defines = []
	if analog:
		defines.append('TT_WITH_ANALOG')

	# Create and run custom flow
	flow_cfg = {
		# Main design properties
		"DESIGN_NAME"    : "tt_um_template",

		# Sources
		"VERILOG_FILES"  : [
			"../../rtl/tt_um_template.v",
		],
		"VERILOG_DEFINES" : defines,

		# Floorplanning
		"DIE_AREA"           :  [0, 0, block_width/1000, block_height/1000 ],
		"FP_SIZING"          : "absolute",
		"BOTTOM_MARGIN_MULT" : 1,
		"TOP_MARGIN_MULT"    : 1,
		"LEFT_MARGIN_MULT"   : 6,
		"RIGHT_MARGIN_MULT"  : 6,

		# Synthesis
		"SYNTH_ELABORATE_ONLY" : True,
	}

	flow = BlockTemplateFlow(
		flow_cfg,
		design_dir = design_dir,
		pdk_root   = PDK_ROOT,
		pdk        = "sky130A",
	)

	flow.start()

	# Collect and rename the build product
	m = list(sorted(glob.glob(os.path.join(design_dir, 'runs', '*', 'final', 'def', 'tt_um_template.def'))))[-1]

	shutil.copyfile(m, f"def/tt_block_{design_dir:s}.def")


if __name__ == '__main__':
	# Load TinyTapeout
	tti = tt.TinyTapeout(modules=False)

	# Create destination directory
	if not os.path.exists("def"):
		os.mkdir("def")

	# Generate block templates for all allowed combinations
	GEN = [
		# Width,                Height,    pg_vdd, pg_vaa, analog
		( [ 1, 2, 3, 4, 6, 8 ], [ 1, 2 ],  True,   False,  False ),
		( [ 1, 2, 3, 4, 6, 8 ], [    2 ],  True,   False,  True  ),
		( [ 1, 2, 3, 4, 6, 8 ], [    2 ],  True,   True ,  True  ),
	]

	for h_list, v_list, pg_vdd, pg_vaa, analog in GEN:
		for v_mult in v_list:
			for h_mult in h_list:
				gen_block_template(tti, h_mult, v_mult, pg_vdd, pg_vaa, analog)
