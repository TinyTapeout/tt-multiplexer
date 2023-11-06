#!/usr/bin/env python3

#
# OpenLane2 build script to harden the tt_top macro inside
# the openframe_project_wrapper
#
# Copyright (c) 2023 Sylvain Munaut <tnt@246tNt.com>
# SPDX-License-Identifier: Apache-2.0
#

import argparse
import json
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
from CustomApplyDEFTemplate import CustomApplyDEFTemplate

sys.path.append('../../py')
import tt


class CustomPower(OdbpyStep):

	id = "TT.Top.CustomPower"
	name = "Custom Power connections for TT Top Level"

	def get_script_path(self):
		return os.path.join(
			os.path.dirname(__file__),
			"odb_power.py"
		)


class CustomRoute(OdbpyStep):

	id = "TT.Top.CustomRoute"
	name = "Custom Pre-Routing for TT Top Level"

	def get_script_path(self):
		return os.path.join(
			os.path.dirname(__file__),
			"odb_route.py"
		)


class TopFlow(SequentialFlow):

	Steps: List[Type[Step]] = [
		Yosys.JsonHeader,
		Yosys.Synthesis,
		Checker.YosysUnmappedCells,
		Checker.YosysSynthChecks,
		OpenROAD.CheckSDCFiles,
		OpenROAD.Floorplan,
		Odb.ApplyDEFTemplate,
		CustomApplyDEFTemplate,
		Odb.SetPowerConnections,
		Odb.ManualMacroPlacement,
		CustomPower,
		OpenROAD.GeneratePDN,
		OpenROAD.GlobalPlacement,
		OpenROAD.DetailedPlacement,
		CustomRoute,
		OpenROAD.GlobalRouting,
		OpenROAD.DetailedRouting,
		Checker.TrDRC,
		Odb.ReportDisconnectedPins,
		Checker.DisconnectedPins,
		Odb.ReportWireLength,
		Checker.WireLength,
		OpenROAD.RCX,
		OpenROAD.STAPostPNR,
# IR drop is broken in openframe (see https://github.com/RTimothyEdwards/caravel_openframe_project/blob/afc3ff66b657b3758690c12b077f9a175acf701c/openlane/openframe_project_wrapper/config.json#L87)
		#OpenROAD.IRDropReport,
		Magic.StreamOut,
		Magic.WriteLEF,
		KLayout.StreamOut,
		KLayout.XOR,
		Checker.XOR,
		Magic.DRC,
		Checker.MagicDRC,
		Magic.SpiceExtraction,
#		Checker.IllegalOverlap,
		Netgen.LVS,
# LVS is currently broken in openframe (see https://github.com/efabless/openframe_timer_example/tinytapeout-05-openframe/commit/e431e03e8d57791ff2149ff392fc554f8fa3ed84)
#		Checker.LVS, 
	]


if __name__ == '__main__':
	# Argument processing
	parser = argparse.ArgumentParser(formatter_class=argparse.ArgumentDefaultsHelpFormatter)
	parser.add_argument("--open-in-klayout", action="store_true", help="Open last run in KLayout")
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
	macros = { 
		'vccd1_connection': {
			'gds': [ 'dir::openframe/vccd1_connection.gds', ],
			'lef': [ 'dir::openframe/vccd1_connection.lef', ],
			'nl': 'dir::openframe/vccd1_connection.v',
			'instances': { 
				'vccd1_connection': {
					'location': [ 3122.515, 4327.51 ],
					'orientation': 'N',
				}
			},
		},
		'vssd1_connection': {
			'gds': [ 'dir::openframe/vssd1_connection.gds', ],
			'lef': [ 'dir::openframe/vssd1_connection.lef', ],
			'nl': 'dir::openframe/vssd1_connection.v',
			'instances': { 
				'vssd1_connection': {
					'location': [ 3122.515, 2088.51 ],
					'orientation': 'N',
				}
			},
		},
		'tt_autosel': {
			'gds': [ 'dir::gds/tt_autosel.gds', ],
			'lef': [ 'dir::lef/tt_autosel.lef', ],
			'nl': 'dir::verilog/tt_autosel.v',
			'instances': {
				'autosel_I': {
					'location': [ 1500, 100 ],
					'orientation': 'N',
				}
			}
		}
	}
	user_modules = []

	for m in tti.die.get_sub_macros():
		if m.mod_name not in macros:
			macros[m.mod_name] = {
				'gds': [ f'dir::gds/{m.mod_name:s}.gds', ],
				'lef': [ f'dir::lef/{m.mod_name:s}.lef', ],
				'instances': { }
			}
			if m.mod_name.startswith('tt_um_'):
				user_modules.append(m.mod_name)
			elif m.mod_name.startswith('tt_pg_'):
				macros[m.mod_name].update({
					'nl': f'dir::verilog/{m.mod_name:s}.v',
				})
			else:
				macros[m.mod_name].update({
					'nl':   f'dir::verilog/{m.mod_name:s}.v',
					'spef': {
						"min_*": [ f'dir::spef/{m.mod_name:s}.min.spef' ],
						"nom_*": [ f'dir::spef/{m.mod_name:s}.nom.spef' ],
						"max_*": [ f'dir::spef/{m.mod_name:s}.max.spef' ],
					},
				})

		macros[m.mod_name]['instances'][m.inst_name] = {
			"location": [ m.pos.x / 1000, m.pos.y / 1000 ],
			"orientation": m.orient,
		}

	# Generate dummy for all user modules
	mod_tpl = open('tt_um_tpl.v', 'r').read()
	open('verilog/tt_um_all.v', 'w').write('\n'.join([
		mod_tpl.format(mod_name=m)
			for m in user_modules
	]))

	# Custom config
	flow_cfg = {
		# Main design properties
		"DESIGN_NAME"    : "openframe_project_wrapper",
		"DESIGN_IS_CORE" : False,

		# Sources
		"VERILOG_FILES": [
			"dir::openframe_project_wrapper.v",
			"dir::../../rtl/tt_top.v",
			"dir::../../rtl/tt_user_module.v",
		],

		# Macros
		"MACROS": macros,
		"EXTRA_VERILOG_MODELS": [
			"dir::verilog/tt_um_all.v",
		],

		# Constraints
		"SIGNOFF_SDC_FILE" : "signoff.sdc",

		# Synthesis
		"SYNTH_ELABORATE_ONLY"      : True,
		"SYNTH_EXCLUSION_CELL_LIST" : "no_synth_cells.txt",
		"PNR_EXCLUSION_CELL_LIST"   : "no_drc_cells.txt",
		"DRC_EXCLUDE_CELL_LIST"     : "no_drc_cells.txt",

		# PDN
		"PDN_CONNECT_MACROS_TO_GRID": False,
		"PDN_ENABLE_GLOBAL_CONNECTIONS": False,
		"PDN_CFG": "pdn.tcl",

		# Routing
		"GRT_ALLOW_CONGESTION"  : True,
		"GRT_REPAIR_ANTENNAS"   : False,
		"GRT_LAYER_ADJUSTMENTS" : [1, 0.95, 0.95, 0, 0, 0],
		"RT_MAX_LAYER"          : "met4",

		# DRC
		"MAGIC_DRC_USE_GDS": True,

		# LVS
		"MAGIC_EXT_SHORT_RESISTOR" : True, # Fixes LVS failures when more than two pins are connected to the same net
	}

	# Load fixed required config for UPW
	flow_cfg.update(json.loads(open('config.json', 'r').read()))

	# Update PDN config
	pdn_width   = 6.2
	pdn_spacing = 2 * pdn_width		# Spacing border to border
	pdn_pitch   = tti.layout.glb.branch.pitch / 5000
	pdn_offset  = (
		tti.layout.glb.top.pos_y +
		(pdn_pitch - tti.layout.glb.margin.y) // 2 -
		(pdn_spacing + pdn_width) // 2 +
		2720 * 3	# ???
	) / 1000

	while pdn_offset > (pdn_pitch * 1.1):
		pdn_offset -= pdn_pitch

	pdn_offset += 27.2 # Fix for openframe PDN grid conflicting with the power gate GPWR wires

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
	flow_kls = OpenInKLayout if args.open_in_klayout else TopFlow
	flow = flow_kls(
		flow_cfg,
		design_dir = ".",
		pdk_root   = PDK_ROOT,
		pdk        = "sky130A",
	)

	flow.start(last_run = args.open_in_klayout)
