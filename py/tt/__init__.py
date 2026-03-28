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
		if val is None:
			return None
		if not os.path.isabs(val):
			val = os.path.join(base, val)
		return val

	@classmethod
	def get_config_file(kls, config=None):
		DEFAULT_CONFIG = {
			'sky130A': 'sky130.yaml',
			'ihp-sg13g2': 'ihp-sg13g2.yaml',
			'ihp-sg13cmos5l': 'ihp-sg13cmos5l.yaml',
		}.get(os.getenv('PDK'))
		return kls._get_data_file(config, 'TT_CONFIG', DEFAULT_CONFIG)

	@classmethod
	def get_modules_file(kls, modules=None):
		return kls._get_data_file(modules, 'TT_MODULES', 'modules_placed.yaml')

	@classmethod
	def get_config(kls, config=None):
		# Determine the config files
		config  = kls.get_config_file(config)
		if config is None:
			raise RuntimeError('Unable to load config. Make sure either PDK and/or TT_CONFIG env var is set')

		# Load actual config
		cfg = ConfigNode.from_yaml(open(config, 'r'))

		# Check PDK
		pdk_env = os.getenv('PDK')
		if (pdk_env is not None) and (pdk_env != cfg.pdk.name):
			raise RuntimeError('Environment variable PDK set to value inconsistent with loaded config file')

		return cfg

