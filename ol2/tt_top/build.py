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

from librelane.common import Path
from librelane.flows.misc import OpenInKLayout
from librelane.flows.sequential import SequentialFlow
from librelane.state import DesignFormat, State
from librelane.steps.openroad import OpenROADStep
from librelane.steps.odb import OdbpyStep
from librelane.steps.step import ViewsUpdate, MetricsUpdate
from librelane.steps import (
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
class FixupBTerms(OdbpyStep):

	id = "TT.Top.FixupBTerms"
	name = "Custom Fixups for TT Top Level"

	def get_script_path(self):
		return os.path.join(
			os.path.dirname(__file__),
			"odb_prune_bterms.py"
		)


@Step.factory.register()
class FixupExtractedNetlist(Step):

	id = "TT.Top.FixupExtractedNetlist"
	name = "Fix netlist port for LVS"

	inputs = [DesignFormat.SPICE]
	outputs = [DesignFormat.SPICE]

	def run(self, state_in: State, **kwargs) -> Tuple[ViewsUpdate, MetricsUpdate]:
		views_updates: ViewsUpdate = {}

		input_spice = state_in[DesignFormat.SPICE]
		output_spice = os.path.join(
			self.step_dir,
			f"{self.config['DESIGN_NAME']}.{DesignFormat.SPICE.extension}"
		)

		script = os.path.join(
			os.path.dirname(__file__),
			"../../py/gf_fixup_netlist.py"
		)

		self.run_subprocess(
			[
				script,
				abspath(input_spice),
				abspath(output_spice),
			],
		)

		views_updates[DesignFormat.SPICE] = Path(output_spice)

		return views_updates, {}


class TopFlow(SequentialFlow):

	Steps: List[Type[Step]] = [
		Yosys.JsonHeader,
		Yosys.Synthesis,
		Checker.YosysUnmappedCells,
		Checker.YosysSynthChecks,
		OpenROAD.Floorplan,
		CustomPower,
		OpenROAD.PadRing,
		FixupBTerms,
		Odb.ManualMacroPlacement,
		OpenROAD.GeneratePDN,
		OpenROAD.GlobalPlacement,
		OpenROAD.DetailedPlacement,
		CustomRoute,
		OpenROAD.GlobalRouting,
		OpenROAD.DetailedRouting,
		Checker.TrDRC,
		OpenROAD.CheckAntennas,
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
#		KLayout.Antenna,
#		Checker.KLayoutAntenna,
#		Magic.DRC,
#		Checker.MagicDRC,
		KLayout.SealRing,
		KLayout.Filler,
		KLayout.Density,
		Checker.KLayoutDensity,
		Magic.SpiceExtraction,
		Checker.IllegalOverlap,
		FixupExtractedNetlist,
		Netgen.LVS,
		Checker.LVS,
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
						"min_*": [ f'dir::spef/{m.mod_name:s}.min.spef' ],
						"nom_*": [ f'dir::spef/{m.mod_name:s}.nom.spef' ],
						"max_*": [ f'dir::spef/{m.mod_name:s}.max.spef' ],
					},
				})

		macros[m.mod_name]['instances'][m.inst_name] = {
			"location": [ m.pos.x.um, m.pos.y.um ],
			"orientation": m.orient,
		}

	macros['gf180mcu_ws_ip__id'] = {
		'gds': [ f'dir::gds/gf180mcu_ws_ip__id.gds', ],
		'lef': [ f'dir::lef/gf180mcu_ws_ip__id.lef', ],
		'instances': {
			'chip_id_I': {
				'location': [ 26.0, 26.0 ],
				'orientation': 'N',
			},
		},
	}
	macros['gf180mcu_ws_ip__logo'] = {
		'gds': [ f'dir::gds/gf180mcu_ws_ip__logo.gds', ],
		'lef': [ f'dir::lef/gf180mcu_ws_ip__logo.lef', ],
		'instances': {
			'logo_I': {
				'location': [ 3762.75, 26.0 ],
				'orientation': 'N',
			},
		},
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
		"DESIGN_NAME"    : "tt_gf_wrapper",
		"DESIGN_IS_CORE" : False,

		# Sources
		"VERILOG_FILES": [
			"dir::tt_gf_wrapper.v",
			"dir::../../rtl/tt_top.v",
			"dir::../../rtl/tt_gf_gpio.v",
			"dir::../../rtl/tt_user_module.v",
		],

		"VERILOG_POWER_DEFINE": "USE_POWER_PINS",

		# Macros
		"MACROS": macros,
		"EXTRA_VERILOG_MODELS": [
			"dir::verilog/tt_um_all.v",
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
		"DIE_AREA"  : [   0.00,   0.00, 3932.00, 5122.00 ],
		"CORE_AREA" : [ 440.00, 440.00, 3492.00, 4682.00 ],
		"FP_SIZING" : "absolute",

		# PDN
		"VDD_NETS": [ "vdpwr", ],
		"GND_NETS": [ "vgnd",  ],

		"PDN_CFG": "dir::pdn.tcl",

		"PDN_CONNECT_MACROS_TO_GRID"    : False,
		"PDN_ENABLE_GLOBAL_CONNECTIONS" : False,

		"FP_PDN_CORE_RING"          : True,
		"FP_PDN_CORE_RING_VWIDTH"   : 27.5,
		"FP_PDN_CORE_RING_HWIDTH"   : 30,
		"FP_PDN_CORE_RING_VOFFSET"  :  0,
		"FP_PDN_CORE_RING_HOFFSET"  :  0,
		"FP_PDN_CORE_RING_VSPACING" :  1.5,
		"FP_PDN_CORE_RING_HSPACING" :  1.5,

		# Routing
		"GRT_ALLOW_CONGESTION"  : True,
		"GRT_REPAIR_ANTENNAS"   : False,
		"RT_MAX_LAYER"          : "Metal4",

		# Magic stream
		"MAGIC_ZEROIZE_ORIGIN" : False,

		# DRC
		"MAGIC_DRC_USE_GDS": True,

		# LVS
		"MAGIC_DEF_LABELS" : False,
		"MAGIC_EXT_UNIQUE": "notopports",
		"MAGIC_EXT_SHORT_RESISTOR" : True, # Fixes LVS failures when more than two pins are connected to the same net
		"LVS_FLATTEN_CELLS": ["tt_logo_top", "tt_logo_bottom", "tt_logo_corner_tl", "tt_logo_corner_tr", "gf180mcu_ws_ip__id", "gf180mcu_ws_ip__logo"],
	}

	flow_cfg.update({
		"VDD_PIN_VOLTAGE": 3.3,
		"DEFAULT_CORNER": "nom_tt_025C_3v30",
		"STA_CORNERS": [
			"nom_tt_025C_3v30",
			"nom_ss_125C_3v00",
			"nom_ff_n40C_3v60",
			"min_tt_025C_3v30",
			"min_ss_125C_3v00",
			"min_ff_n40C_3v60",
			"max_tt_025C_3v30",
			"max_ss_125C_3v00",
			"max_ff_n40C_3v60",
		],
		"PAD_CELL_LIBRARY": "gf180mcu_ocd_io",
		"PAD_GDS": [
			"pdk_dir::libs.ref/gf180mcu_ocd_io/gds/gf180mcu_ocd_io.gds",
		],
		"PAD_CDLS": [],
		"LIB": {
			"*_tt_025C_3v30": [
				"pdk_dir::libs.ref/gf180mcu_fd_sc_mcu7t5v0/lib/gf180mcu_fd_sc_mcu7t5v0__tt_025C_3v30.lib",
				"pdk_dir::libs.ref/gf180mcu_ocd_io/lib/gf180mcu_ocd_io__tt_025C_3v30.lib",
			],
			"*_ss_125C_3v00": [
				"pdk_dir::libs.ref/gf180mcu_fd_sc_mcu7t5v0/lib/gf180mcu_fd_sc_mcu7t5v0__ss_125C_3v00.lib",
				"pdk_dir::libs.ref/gf180mcu_ocd_io/lib/gf180mcu_ocd_io__ss_125C_2v97.lib",
			],
			"*_ff_n40C_3v60": [
				"pdk_dir::libs.ref/gf180mcu_fd_sc_mcu7t5v0/lib/gf180mcu_fd_sc_mcu7t5v0__ff_n40C_3v60.lib",
				"pdk_dir::libs.ref/gf180mcu_ocd_io/lib/gf180mcu_ocd_io__ff_n40C_3v63.lib",
			],
		},
		"KLAYOUT_FILLER_OPTIONS": {
			"Metal2_ignore_active": True,
		},
	})

	# Pad config
	flow_cfg["PAD_SOUTH"] = [ f"gpio\\[{i}\\].gpio_I.genblk1.pad_I" for i in range( 0,17) ]
	flow_cfg["PAD_EAST"]  = [ f"gpio\\[{i}\\].gpio_I.genblk1.pad_I" for i in range(17,37) ]
	flow_cfg["PAD_NORTH"] = [ f"gpio\\[{i}\\].gpio_I.genblk1.pad_I" for i in reversed(range(37,54)) ]
	flow_cfg["PAD_WEST"]  = [ f"gpio\\[{i}\\].gpio_I.genblk1.pad_I" for i in reversed(range(54,74)) ]

	# Update PDN config
	pdn_width   = 14.50
	pdn_spacing =  1.10
	pdn_pitch   = (tti.layout.glb.branch.pitch // 5).um
	pdn_offset  = (
		tti.layout.glb.top.pos_y +
		tti.layout.glb.branch.pitch // 10 -
		tti.layout.glb.margin.y // 2
	).um
	pdn_offset -= (pdn_spacing + pdn_width)

	sh = tti.cfg.pdk.site.height.um
	if 'CORE_AREA' in flow_cfg:
		pdn_offset -= math.ceil(flow_cfg['CORE_AREA'][1] / sh) * sh
	else:
		pdn_offset -= sh * flow_cfg.get('BOTTOM_MARGIN_MULT', 4)

	while pdn_offset > (pdn_pitch * 1.1):
		pdn_offset -= pdn_pitch

	def pdn_align(x):
		grid = 0.005
		return round(x / grid) * grid

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
		pdk        = tti.cfg.pdk.name,
	)

	flow.start(last_run = args.open_in_klayout)
