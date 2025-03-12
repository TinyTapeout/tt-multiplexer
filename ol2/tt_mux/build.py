#!/usr/bin/env python3

#
# OpenLane2 build script to harden the tt_mux macro
#
# Copyright (c) 2023 Sylvain Munaut <tnt@246tNt.com>
# SPDX-License-Identifier: Apache-2.0
#

import argparse
import os
import sys

from typing import List, Type

from openlane.flows.misc import OpenInKLayout
from openlane.flows.sequential import SequentialFlow
from openlane.steps.odb import OdbpyStep
from openlane.steps import (
	Step,
	Yosys,
	OpenROAD,
	Magic,
	Misc,
	KLayout,
	Odb,
	Netgen,
	Checker,
)

sys.path.append('../../py')
import tt


@Step.factory.register()
class IOPlacement(OdbpyStep):

	id = "TT.Mux.IOPlacement"
	name = "Custom IO placement for TT Mux module"

	def get_script_path(self):
		return os.path.join(
			os.path.dirname(__file__),
			"odb_ioplace.py"
		)


class MuxFlow(SequentialFlow):

	Steps: List[Type[Step]] = [
		Yosys.Synthesis,
		Checker.YosysUnmappedCells,
#		Checker.YosysSynthChecks,	# FIXME: Doesn't support tristate
		OpenROAD.CheckSDCFiles,
		OpenROAD.Floorplan,
		IOPlacement,
		OpenROAD.GeneratePDN,
		OpenROAD.GlobalPlacement,
		OpenROAD.DetailedPlacement,
		OpenROAD.GlobalRouting,
		OpenROAD.DetailedRouting,
		Checker.TrDRC,
		Odb.ReportDisconnectedPins,
		Checker.DisconnectedPins,
		Odb.ReportWireLength,
		Checker.WireLength,
		OpenROAD.FillInsertion,
		OpenROAD.RCX,
		OpenROAD.STAPostPNR,
		OpenROAD.IRDropReport,
		OpenROAD.WriteAbstractLEF,
		OpenROAD.WriteCDL,
		Magic.StreamOut,
		Magic.WriteLEF,
		KLayout.StreamOut,
		KLayout.XOR,
		Checker.XOR,
		Magic.DRC,
		Checker.MagicDRC,
		KLayout.DRC,
		Checker.KLayoutDRC,
		Magic.SpiceExtraction,
		Checker.IllegalOverlap,
		Netgen.LVS,
		Checker.LVS,
		KLayout.LVS,
		Checker.LVS,
	]


if __name__ == '__main__':
	# Argument processing
	parser = argparse.ArgumentParser(formatter_class=argparse.ArgumentDefaultsHelpFormatter)
	parser.add_argument("--open-in-klayout", action="store_true", help="Open last run in KLayout")

	args = parser.parse_args()

	# Get PDK root out of environment
	PDK_ROOT = os.getenv('PDK_ROOT')
	PDK      = os.getenv('PDK')

	# Load TinyTapeout
	tti = tt.TinyTapeout(modules=False)

	# Create and run custom flow
	verilog_files = [
		"dir::../../rtl/tt_mux.v",
		"dir::../../rtl/prim_ihp-sg13g2/tt_prim_buf.v",
		"dir::../../rtl/prim_ihp-sg13g2/tt_prim_dfrbp.v",
		"dir::../../rtl/prim_ihp-sg13g2/tt_prim_diode.v",
		"dir::../../rtl/prim_ihp-sg13g2/tt_prim_inv.v",
		"dir::../../rtl/prim_ihp-sg13g2/tt_prim_mux2.v",
		"dir::../../rtl/prim_ihp-sg13g2/tt_prim_mux4.v",
		"dir::../../rtl/prim_ihp-sg13g2/tt_prim_tbuf.v",
		"dir::../../rtl/prim_ihp-sg13g2/tt_prim_tie.v",
		"dir::../../rtl/prim_ihp-sg13g2/tt_prim_tbuf_pol.v",
		"dir::../../rtl/prim_ihp-sg13g2/tt_prim_zbuf.v",
	]

	flow_cfg = {
		# Main design properties
		"DESIGN_NAME"    : "tt_mux",
		"DESIGN_IS_CORE" : False,

		# Sources
		"VERILOG_INCLUDE_DIRS" : [ "dir::../../rtl/" ],
		"VERILOG_FILES"        : verilog_files,

		# Constraints
		"SIGNOFF_SDC_FILE" : "dir::signoff.sdc",

		# Synthesis
		"SYNTH_READ_BLACKBOX_LIB"     : True,
		"SYNTH_DIRECT_WIRE_BUFFERING" : False,
		"SYNTH_ABC_BUFFERING"         : False,

		# Floorplanning
		"DIE_AREA"           : [0, 0, tti.layout.glb.mux.width/1000, tti.layout.glb.mux.height/1000 ],
		"FP_SIZING"          : "absolute",
		"BOTTOM_MARGIN_MULT" : 1,
		"TOP_MARGIN_MULT"    : 1,
		"LEFT_MARGIN_MULT"   : 6,
		"RIGHT_MARGIN_MULT"  : 6,

		# Placement
		"PL_TIME_DRIVEN" : False,			# Disable resizer

		# Routing
		"DIODE_PADDING"        : 0,
		"GRT_ALLOW_CONGESTION" : True,
		"RT_MAX_LAYER"         : "Metal5",

		# LEF generation option
		"MAGIC_LEF_WRITE_USE_GDS" : False,	# Workaround LEF/GDS pin naming issue
		"MAGIC_WRITE_LEF_PINONLY" : True,

		# LVS
		"MAGIC_DEF_LABELS": False,			# Avoid exporting useless internal labels
	}

	flow_kls = OpenInKLayout if args.open_in_klayout else MuxFlow
	flow = flow_kls(
		flow_cfg,
		design_dir = ".",
		pdk_root   = PDK_ROOT,
		pdk        = PDK,
	)

	flow.start(last_run = args.open_in_klayout)
