#!/usr/bin/env python3

#
# OpenLane2 build script to harden the tt_mux macro
#
# Copyright (c) 2023 Sylvain Munaut <tnt@246tNt.com>
# SPDX-License-Identifier: Apache-2.0
#

import os
import sys

from typing import List, Type

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


class IOPlacement(OdbpyStep):

	id = "TT.Mux.IOPlacement"
	name = "Custom IO placement for TT Mux module"

	def get_script_path(self):
		return os.path.join(
			os.path.dirname(__file__),
			"odb_ioplace.py"
		)

	def get_command(sef) -> List[str]:
		return super().get_command()


class MuxTemplateFlow(SequentialFlow):

	Steps: List[Type[Step]] = [
		Yosys.Synthesis,
		Misc.LoadBaseSDC,
		OpenROAD.Floorplan,
		IOPlacement,
	]


class MuxFlow(SequentialFlow):

	Steps: List[Type[Step]] = [
		Yosys.Synthesis,
		Checker.YosysUnmappedCells,
#		Checker.YosysSynthChecks,	# FIXME: Doesn't support tristate
		Misc.LoadBaseSDC,
		OpenROAD.Floorplan,
		OpenROAD.TapEndcapInsertion,
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
#		OpenROAD.STAPostPNR,	# FIXME
		OpenROAD.IRDropReport,
		Magic.StreamOut,
		Magic.WriteLEF,
		KLayout.StreamOut,
		KLayout.XOR,
		Checker.XOR,
		Magic.DRC,
		Checker.MagicDRC,
		Magic.SpiceExtraction,
		Checker.IllegalOverlap,
		Netgen.LVS,
		Checker.LVS,
	]


if __name__ == '__main__':
	# Get PDK root out of environment
	PDK_ROOT = os.getenv('PDK_ROOT')

	# Load TinyTapeout
	tti = tt.TinyTapeout(modules=False)

	# Create and run custom flow
	verilog_files = []

	if int(os.getenv('TT_TEMPLATE', 0)):
		verilog_files.append("../../rtl/tt_mux_template.v")
		flow_kls = MuxTemplateFlow
	else:
		verilog_files.append("../../rtl/tt_mux.v")
		flow_kls = MuxFlow

	verilog_files += [
		"../../rtl/prim_sky130/tt_prim_buf.v",
		"../../rtl/prim_sky130/tt_prim_dfrbp.v",
		"../../rtl/prim_sky130/tt_prim_diode.v",
		"../../rtl/prim_sky130/tt_prim_inv.v",
		"../../rtl/prim_sky130/tt_prim_mux4.v",
		"../../rtl/prim_sky130/tt_prim_tbuf.v",
		"../../rtl/prim_sky130/tt_prim_tie.v",
		"../../rtl/prim_sky130/tt_prim_tbuf_pol.v",
		"../../rtl/prim_sky130/tt_prim_zbuf.v",
	]

	flow_cfg = {
		# Main design properties
		"DESIGN_NAME"    : "tt_mux",
		"DESIGN_IS_CORE" : False,

		# Sources
		"VERILOG_INCLUDE_DIRS" : [ "../../rtl/" ],
		"VERILOG_FILES"        : verilog_files,

		# Synthesis
		"SYNTH_READ_BLACKBOX_LIB"   : "1",
		"SYNTH_EXCLUSION_CELL_LIST" : "no_synth_cells.txt",
		"SYNTH_BUFFERING"           : False,

		# Floorplanning
		"DIE_AREA"           : f"0 0 {tti.layout.glb.mux.width.units/1000:.3f} {tti.layout.glb.mux.height.units/1000:.3f}",
		"FP_SIZING"          : "absolute",
		"BOTTOM_MARGIN_MULT" : 1,
		"TOP_MARGIN_MULT"    : 1,
		"LEFT_MARGIN_MULT"   : 6,
		"RIGHT_MARGIN_MULT"  : 6,

		# Routing
		"GRT_ALLOW_CONGESTION" : True,
		"RT_MAX_LAYER"         : "met4",

		# Workaround LEF/GDS pin naming issue
		"MAGIC_LEF_WRITE_USE_GDS" : False,
	}

	flow = flow_kls(
		flow_cfg,
		design_dir = ".",
		pdk_root   = PDK_ROOT,
		pdk        = "sky130A",
	)

	flow.start()
