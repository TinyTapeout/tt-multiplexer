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


def gen_block_template(tti, h_mult, v_mult):
	# Get PDK root out of environment
	PDK_ROOT = os.getenv('PDK_ROOT')

	# Create directory
	design_dir = f"{h_mult:d}x{v_mult:d}"
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

	# Create and run custom flow
	flow_cfg = {
		# Main design properties
		"DESIGN_NAME"    : "tt_um_template",

		# Sources
		"VERILOG_FILES"  : [
			"../../rtl/tt_um_template.v",
		],

		# Floorplanning
		"DIE_AREA"           :  f"0 0 {block_width/1000:.3f} {block_height/1000:.3f}",
		"FP_SIZING"          : "absolute",
		"BOTTOM_MARGIN_MULT" : 1,
		"TOP_MARGIN_MULT"    : 1,
		"LEFT_MARGIN_MULT"   : 6,
		"RIGHT_MARGIN_MULT"  : 6,
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

	shutil.copyfile(m, f"def/tt_block_{h_mult:d}x{v_mult:d}.def")


if __name__ == '__main__':
	# Load TinyTapeout
	tti = tt.TinyTapeout(modules=False)

	# Create destination directory
	if not os.path.exists("def"):
		os.mkdir("def")

	# Generate block templates for all supported sizes
	for v_mult in [ 1, 2 ]:
		for h_mult in [ 1, 2, 3, 4, 8 ]:
			gen_block_template(tti, h_mult, v_mult)
