#!/usr/bin/env python3

#
# OpenLane2 build script to harden the tt_ctrl macro
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

	id = "TT.Ctrl.IOPlacement"
	name = "Custom IO placement for TT Control module"

	def get_script_path(self):
		return os.path.join(
			os.path.dirname(__file__),
			"odb_ioplace.py"
		)


class CtrlFlow(SequentialFlow):

	Steps: List[Type[Step]] = [
		Yosys.Synthesis,
		Checker.YosysUnmappedCells,
#		Checker.YosysSynthChecks,	# FIXME: Doesn't support tristate
		OpenROAD.CheckSDCFiles,
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
		OpenROAD.STAPostPNR,
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

	# Compute the PDN data to fit right in the vspine gap
	lim_pts = [
		tti.layout.ply_ctrl_vspine[f'spine_ow[{tti.layout.vspine.ow-1:d}]'],
		tti.layout.ply_ctrl_vspine[ 'spine_ow[0]'],
		tti.layout.ply_ctrl_vspine[f'spine_iw[{tti.layout.vspine.iw-1:d}]'],
		tti.layout.ply_ctrl_vspine[ 'spine_iw[0]'],
	]

	pdn_vwidth   = 1600
	pdn_vspacing = 1700
	pdn_vpitch = (pdn_vwidth + pdn_vspacing) * 3 + max(
		lim_pts[1] - lim_pts[0],
		lim_pts[3] - lim_pts[2],
	)
	pdn_voffset = (lim_pts[1] + lim_pts[2] - pdn_vwidth - pdn_vspacing) // 2 - pdn_vpitch
	pdn_voffset -= 6 * tti.layout.cfg.pdk.site.width	# Margin

	# Create and run custom flow
	verilog_files = [
		"../../rtl/tt_ctrl.v",
		"../../rtl/prim_sky130/tt_prim_buf.v",
		"../../rtl/prim_sky130/tt_prim_dfrbp.v",
		"../../rtl/prim_sky130/tt_prim_diode.v",
		"../../rtl/prim_sky130/tt_prim_inv.v",
		"../../rtl/prim_sky130/tt_prim_mux2.v",
		"../../rtl/prim_sky130/tt_prim_mux4.v",
		"../../rtl/prim_sky130/tt_prim_tbuf.v",
		"../../rtl/prim_sky130/tt_prim_tie.v",
		"../../rtl/prim_sky130/tt_prim_tbuf_pol.v",
		"../../rtl/prim_sky130/tt_prim_zbuf.v",
	]

	flow_cfg = {
		# Main design properties
		"DESIGN_NAME"    : "tt_ctrl",
		"DESIGN_IS_CORE" : False,

		# Sources
		"VERILOG_INCLUDE_DIRS" : [ "../../rtl/" ],
		"VERILOG_FILES"        : verilog_files,

		# Constraints
		"SIGNOFF_SDC_FILE" : "signoff.sdc",

		# Synthesis
		"SYNTH_READ_BLACKBOX_LIB"     : True,
		"SYNTH_DIRECT_WIRE_BUFFERING" : False,
		"SYNTH_ABC_BUFFERING"         : False,

		# Floorplanning
		"DIE_AREA"           : [0, 0, tti.layout.glb.ctrl.width/1000, tti.layout.glb.ctrl.height/1000],
		"FP_SIZING"          : "absolute",
		"BOTTOM_MARGIN_MULT" : 1,
		"TOP_MARGIN_MULT"    : 1,
		"LEFT_MARGIN_MULT"   : 6,
		"RIGHT_MARGIN_MULT"  : 6,

		# PDN
		"PDN_CFG"         : "pdn.tcl",
		"FP_PDN_VPITCH"   : pdn_vpitch   / 1000,
		"FP_PDN_VOFFSET"  : pdn_voffset  / 1000,
		"FP_PDN_VSPACING" : pdn_vspacing / 1000,
		"FP_PDN_VWIDTH"   : pdn_vwidth   / 1000,

		# Placement
		"PL_TARGET_DENSITY_PCT" : 40,

		# Routing
		"DIODE_PADDING" : 0,
		"RT_MAX_LAYER"  : "met4",

		# Workaround LEF/GDS pin naming issue
		"MAGIC_LEF_WRITE_USE_GDS" : False,
	}

	flow = CtrlFlow(
		flow_cfg,
		design_dir = ".",
		pdk_root   = PDK_ROOT,
		pdk        = "sky130A",
	)

	flow.start()
