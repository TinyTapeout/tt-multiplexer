#!/usr/bin/env python3

#
# Top Level of python classes for Tiny Tapeout mux system
#
# Copyright (c) 2023 Sylvain Munaut <tnt@246tNt.com>
# SPDX-License-Identifier: Apache-2.0
#

import os

from .utils import *
from .placer import *
from .layout import *
from .elements import *


class TinyTapeout:

	def __init__(self, config=None, modules=None):
		# Generic config / layout
		self.cfg    = self.get_config(config)
		self.layout = Layout(self.cfg)

		# Modules placement
		if modules is not False:
			# Get module file
			modules = self.get_modules_file(modules)

			# Placer / Elements
			self.placer = ModulePlacer(self.cfg, modules)
			self.die    = Die(self.layout, self.placer)

	@classmethod
	def _get_data_file(kls, user_val, env_var, default_val):
		base = os.path.abspath(os.path.join(os.path.dirname(__file__), os.path.pardir, os.path.pardir, 'cfg'))
		val = os.getenv(env_var, user_val) or default_val
		if not os.path.isabs(val):
			val = os.path.join(base, val)
		return val

	@classmethod
	def get_config_file(kls, config=None):
		return kls._get_data_file(config, 'TT_CONFIG', 'sky130.yaml')

	@classmethod
	def get_modules_file(kls, modules=None):
		return kls._get_data_file(modules, 'TT_MODULES', 'modules_placed.yaml')

	@classmethod
	def get_config(kls, config=None):
		# Determine the config files
		config  = kls.get_config_file(config)
		# Load actual config
		cfg = ConfigNode.from_yaml(open(config, 'r'))

		return cfg

