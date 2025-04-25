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
import math
import os
import sys

from os.path import abspath
from typing import List, Tuple, Type

from openlane.common import Path
from openlane.flows.misc import OpenInKLayout
from openlane.flows.sequential import SequentialFlow
from openlane.state import DesignFormat, State
from openlane.steps.klayout import KLayoutStep
from openlane.steps.odb import OdbpyStep
from openlane.steps.openroad import OpenROADStep
from openlane.steps.step import ViewsUpdate, MetricsUpdate
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
class CustomPower(OdbpyStep):

	id = "TT.Top.CustomPower"
	name = "Custom Power connections for TT Top Level"

	def get_script_path(self):
		return os.path.join(
			os.path.dirname(__file__),
			"odb_power.py"
		)


@Step.factory.register()
class CustomRoute(OdbpyStep):

	id = "TT.Top.CustomRoute"
	name = "Custom Pre-Routing for TT Top Level"

	def get_script_path(self):
		return os.path.join(
			os.path.dirname(__file__),
			"odb_route.py"
		)


@Step.factory.register()
class PadRing(OpenROADStep):

	id = "TT.Top.PadRing"
	name = "Creates Pad Ring"

	def get_script_path(self):
		return os.path.join(
			os.path.dirname(__file__),
			"padring.tcl"
		)


@Step.factory.register()
class IHPExtractSpice(Step):

	id = "TT.IHP.ExtractSpice"
	name = "Extracts SPICE netlist from GDS using metal only"

	inputs = [DesignFormat.GDS]
	outputs = [DesignFormat.SPICE]

	def run(self, state_in: State, **kwargs) -> Tuple[ViewsUpdate, MetricsUpdate]:
		views_updates: ViewsUpdate = {}

		input_gds = state_in[DesignFormat.GDS]
		output_spice = os.path.join(
			self.step_dir,
			f"{self.config['DESIGN_NAME']}.{DesignFormat.SPICE.value.extension}"
		)

		script = os.path.join(
			os.path.dirname(__file__),
			"../../py/ihp_extract_spice.py"
		)

		self.run_subprocess(
			[
				script,
				abspath(input_gds),
				abspath(output_spice),
			],
		)

		views_updates[DesignFormat.SPICE] = Path(output_spice)

		return views_updates, {}


@Step.factory.register()
class IHPSealRing(KLayoutStep):

	id = "TT.IHP.SealRing"
	name = "Adds Seal Ring to the GDS"

	inputs = [DesignFormat.GDS]
	outputs = [DesignFormat.GDS]

	def run(self, state_in: State, **kwargs) -> Tuple[ViewsUpdate, MetricsUpdate]:
		views_updates: ViewsUpdate = {}

		input_gds = state_in[DesignFormat.GDS]
		output_gds = os.path.join(
			self.step_dir,
			f"{self.config['DESIGN_NAME']}.{DesignFormat.GDS.value.extension}"
		)

		script = os.path.join(
			os.path.dirname(__file__),
			"../../py/ihp_seal_ring.py"
		)

		self.run_pya_script(
			[
				script,
				"--input-gds",
				abspath(input_gds),
				"--output-gds",
				abspath(output_gds),
				"--die-width",
				f"{self.config['DIE_AREA'][2]:f}",
				"--die-height",
				f"{self.config['DIE_AREA'][3]:f}",
			],
		)

		views_updates[DesignFormat.GDS] = Path(output_gds)

		return views_updates, {}


class TopFlow(SequentialFlow):

	Steps: List[Type[Step]] = [
		Yosys.JsonHeader,
		Yosys.Synthesis,
		Checker.YosysUnmappedCells,
		Checker.YosysSynthChecks,
		OpenROAD.Floorplan,
		CustomPower,
		PadRing,
		Odb.ManualMacroPlacement,
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
		OpenROAD.IRDropReport,
		Magic.StreamOut,
		KLayout.StreamOut,
		KLayout.XOR,
		Checker.XOR,

		IHPExtractSpice,
		Netgen.LVS,
		Checker.LVS,

#		Magic.SpiceExtraction,
#		Checker.IllegalOverlap,
#		Netgen.LVS,
#		Checker.LVS,

		KLayout.DRC,
		Checker.KLayoutDRC,

#		Magic.DRC,
#		Checker.MagicDRC,

		IHPSealRing,
	]


if __name__ == '__main__':
	# Argument processing
	parser = argparse.ArgumentParser(formatter_class=argparse.ArgumentDefaultsHelpFormatter)
	parser.add_argument("--open-in-klayout", action="store_true", help="Open last run in KLayout")

	args = parser.parse_args()
	config = vars(args)

	# Get PDK root out of environment
	PDK_ROOT = os.getenv('PDK_ROOT')
	PDK      = os.getenv('PDK')

	# Load TinyTapeout
	tti = tt.TinyTapeout()

	# Generate macros
	macros = { }
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
			elif m.mod_name.startswith('tt_pg_') or m.mod_name.startswith('tt_asw_') or m.mod_name.startswith('tt_logo_'):
				macros[m.mod_name].update({
					'nl': f'dir::verilog/{m.mod_name:s}.v',
				})
			else:
				macros[m.mod_name].update({
					'nl':   f'dir::verilog/{m.mod_name:s}.v',
					'spef': {
#						"min_*": [ f'dir::spef/{m.mod_name:s}.min.spef' ],
						"nom_*": [ f'dir::spef/{m.mod_name:s}.nom.spef' ],
#						"max_*": [ f'dir::spef/{m.mod_name:s}.max.spef' ],
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
		"DESIGN_NAME"    : "tt_ihp_wrapper",
		"DESIGN_IS_CORE" : False,

		# Sources
		"VERILOG_FILES": [
			"dir::tt_ihp_wrapper.v",
			"dir::../../rtl/tt_top.v",
			"dir::../../rtl/tt_ihp_gpio.v",
			"dir::../../rtl/tt_user_module.v",
		],

		"VERILOG_POWER_DEFINE": "USE_POWER_PINS",

		# Macros
		"MACROS": macros,
		"EXTRA_VERILOG_MODELS": [
			"dir::verilog/tt_um_all.v",
		],
		"EXTRA_LIBS": [
			"pdk_dir::libs.ref/sg13g2_io/lib/sg13g2_io_dummy.lib",
		],
		"EXTRA_LEFS": [
			"pdk_dir::libs.ref/sg13g2_io/lef/sg13g2_io.lef",
			"dir::lef/bondpad_70x70.lef",
		],
		"EXTRA_GDS_FILES": [
			"pdk_dir::libs.ref/sg13g2_io/gds/sg13g2_io.gds",
			"dir::gds/bondpad_70x70.gds",
		],

		# Constraints
		"SIGNOFF_SDC_FILE" : "dir::signoff.sdc",

		# Synthesis
		"SYNTH_ELABORATE_ONLY"      : True,
		"SYNTH_USE_PG_PINS_DEFINES" : "USE_POWER_PINS",

		"SYNTH_EXCLUSION_CELL_LIST" : "dir::no_synth_cells.txt",
		"PNR_EXCLUSION_CELL_LIST"   : "dir::no_drc_cells.txt",
		"DRC_EXCLUDE_CELL_LIST"     : "dir::no_drc_cells.txt",

		"QUIT_ON_SYNTH_CHECKS"      : False,

		# Floorplanning
#		"DIE_AREA"  : [   0.00,   0.00, 3600.00, 5000.00 ],
#		"CORE_AREA" : [ 425.00, 425.00, 3175.00, 4575.00 ],

#		"DIE_AREA"  : [   0.00,   0.00, 4500.00, 7300.00 ],
#		"CORE_AREA" : [ 425.00, 425.00, 4075.00, 6875.00 ],

		"DIE_AREA"  : [   0.00,   0.00, 2000, 2490.28 ],
		"CORE_AREA" : [ 425.00, 440.00, 1575, 2050.28 ],

		"FP_SIZING" : "absolute",

		# PDN
		"VDD_NETS": [ "vdpwr", "vapwr" ],
		"GND_NETS": [ "vgnd",  "vgnd"  ],

		"PDN_CFG": "dir::pdn.tcl",

		"PDN_CONNECT_MACROS_TO_GRID"    : False,
		"PDN_ENABLE_GLOBAL_CONNECTIONS" : False,

		"FP_PDN_CORE_RING"          : True,
		"FP_PDN_CORE_RING_VWIDTH"   : 25,
		"FP_PDN_CORE_RING_HWIDTH"   : 25,
		"FP_PDN_CORE_RING_VOFFSET"  :  0,
		"FP_PDN_CORE_RING_HOFFSET"  :  0,
		"FP_PDN_CORE_RING_VSPACING" :  2.0,
		"FP_PDN_CORE_RING_HSPACING" :  2.0,

		# Routing
		"GRT_ALLOW_CONGESTION"  : True,
		"GRT_REPAIR_ANTENNAS"   : False,
		"RT_MAX_LAYER"          : "Metal5",

		# Magic stream
		"MAGIC_ZEROIZE_ORIGIN" : False,
#		"PRIMARY_GDSII_STREAMOUT_TOOL": "klayout", # Hack

		# DRC
		"MAGIC_DRC_USE_GDS": True,
		"KLAYOUT_DRC_RUNSET": f"{os.getenv("PDK_ROOT")}/{os.getenv("PDK")}/libs.tech/klayout/tech/drc/sg13g2_maximal.lydrc",

		# LVS
#		"MAGIC_EXT_USE_GDS": True,	# Hack
		"MAGIC_DEF_LABELS" : False,
		"MAGIC_EXT_SHORT_RESISTOR" : True, # Fixes LVS failures when more than two pins are connected to the same net
		"LVS_FLATTEN_CELLS": ["tt_logo_top", "tt_logo_bottom"],
	}

	# Update PDN config
	pdn_width   =  11.0
	pdn_spacing =  3.0
	pdn_pitch   = tti.layout.glb.branch.pitch / 5000
	pdn_offset  = (
		tti.layout.glb.top.pos_y +
		tti.layout.glb.branch.pitch // 10 -
		tti.layout.glb.margin.y // 2
	) / 1000
	pdn_offset -= (pdn_spacing + pdn_width)

	sh = tti.cfg.pdk.site.height / 1000
	if 'CORE_AREA' in flow_cfg:
		pdn_offset -= math.ceil(flow_cfg['CORE_AREA'][1] / sh) * sh
	else:
		pdn_offset -= sh * flow_cfg.get('BOTTOM_MARGIN_MULT', 4)

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
	flow_kls = OpenInKLayout if args.open_in_klayout else TopFlow
	flow = flow_kls(
		flow_cfg,
		design_dir = ".",
		pdk_root   = PDK_ROOT,
		pdk        = PDK,
	)

	flow.start(last_run = args.open_in_klayout)
