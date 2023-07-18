#!/usr/bin/env python3

#
# OpenLane2 build script to harden the tt_top macro inside
# the classic user_project_wrapper
#
# Copyright (c) 2023 Sylvain Munaut <tnt@246tNt.com>
# SPDX-License-Identifier: Apache-2.0
#

import argparse
import json
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


class CustomRoute(OdbpyStep):

	id = "TT.Top.CustomRoute"
	name = "Custom Pre-Routing for TT Top Level"

	def get_script_path(self):
		return os.path.join(
			os.path.dirname(__file__),
			"odb_route.py"
		)

	def get_command(sef) -> List[str]:
		return super().get_command()


class TopFlow(SequentialFlow):

	Steps: List[Type[Step]] = [
		Yosys.JsonHeader,
		Yosys.Synthesis,
		Checker.YosysUnmappedCells,
		Checker.YosysSynthChecks,
		Misc.LoadBaseSDC,
		OpenROAD.Floorplan,
		Odb.ApplyDEFTemplate,
		Odb.SetPowerConnections,
		Odb.ManualMacroPlacement,
		OpenROAD.GeneratePDN,
		OpenROAD.GlobalPlacement,
		OpenROAD.DetailedPlacement,
		CustomRoute,
		OpenROAD.GlobalRouting,
		OpenROAD.DetailedRouting,
		CustomRoute,
		Checker.TrDRC,
		Odb.ReportDisconnectedPins,
		Checker.DisconnectedPins,
		Odb.ReportWireLength,
		Checker.WireLength,
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
	# Argument processing
	parser = argparse.ArgumentParser(formatter_class=argparse.ArgumentDefaultsHelpFormatter)
	parser.add_argument("--skip-xor-checks", action="store_true", help="Skips XOR checks")

	args = parser.parse_args()
	config = vars(args)

	if config['skip_xor_checks']:
		TopFlow.Steps.remove(KLayout.XOR)
		TopFlow.Steps.remove(Checker.XOR)

	# Get PDK root out of environment
	PDK_ROOT = os.getenv('PDK_ROOT')

	# Load TinyTapeout
	tti = tt.TinyTapeout()

	# Generate macros
	macros = { }
	macros_models = [ ]

	for m in tti.die.get_sub_macros():
		if m.mod_name not in macros:
			macros[m.mod_name] = {
				'gds': [ f'dir::gds/{m.mod_name:s}.gds', ],
				'lef': [ f'dir::lef/{m.mod_name:s}.lef', ],
				'instances': { }
			}
			if m.mod_name.startswith('tt_um_'):
				macros_models.append(f'dir::verilog/{m.mod_name:s}.v')

		macros[m.mod_name]['instances'][m.inst_name] = {
			"location": [ m.pos.x / 1000, m.pos.y / 1000 ],
			"orientation": m.orient,
		}

	# Custom config
	flow_cfg = {
		# Main design properties
		"DESIGN_NAME"    : "user_project_wrapper",
		"DESIGN_IS_CORE" : False,

		# Sources
		"VERILOG_FILES": [
			"user_project_wrapper.v",
			"../../rtl/tt_top.v",
			"../../rtl/tt_user_module.v",
		],

		# Macros
		"EXTRA_VERILOG_MODELS": [
			"../../rtl/tt_ctrl.v",
			"../../rtl/tt_mux.v",
		] + macros_models,
		"MACROS": macros,

		# PDN
		"PDN_CFG": "pdn.tcl",

		# Routing
		"GRT_ALLOW_CONGESTION"  : True,
		"GRT_REPAIR_ANTENNAS"   : False,
		"GRT_LAYER_ADJUSTMENTS" : "1, 0.95, 0.95, 0, 0, 0",
		"RT_MAX_LAYER"          : "met4",

		# DRC
		"MAGIC_DRC_USE_GDS": True,

		# Workaround the LEF generation hanging issue
		"MAGIC_LEF_WRITE_USE_GDS" : False,
	}

	# Load fixed required config for UPW
	flow_cfg.update(json.loads(open('config.json', 'r').read()))

	# Update PDN config
	pdn_width   = 3.1
	pdn_spacing = 5 * pdn_width		# Spacing border to border
	pdn_pitch   = tti.layout.glb.branch.pitch / 5000
	pdn_offset  = (
		tti.layout.glb.top.pos_y +
		(pdn_pitch - tti.layout.glb.margin.y) // 2 -
		(pdn_spacing + pdn_width) // 2 +
		2720 * 3	# ???
	) / 1000

	while pdn_offset > (pdn_pitch * 1.1):
		pdn_offset -= pdn_pitch

	def pdn_align(x):
		grid = 0.005
		return int(x / grid) * grid

	flow_cfg.update({
		"FP_PDN_HWIDTH"  : pdn_align(pdn_width),
		"FP_PDN_HSPACING": pdn_align(pdn_spacing),
		"FP_PDN_HPITCH"  : pdn_align(pdn_pitch),
		"FP_PDN_HOFFSET" : pdn_align(pdn_offset),
	})

	# Run flow
	flow = TopFlow(
		flow_cfg,
		design_dir = ".",
		pdk_root   = PDK_ROOT,
		pdk        = "sky130A",
	)

	flow.start()
